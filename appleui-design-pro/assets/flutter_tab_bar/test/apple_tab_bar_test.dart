import 'dart:io';
import 'dart:ui' as ui;

import 'package:appleui_tab_bar_example/apple_tab_bar.dart';
import 'package:appleui_tab_bar_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const reviewFont = String.fromEnvironment('TAB_BAR_FONT');
  setUpAll(() async {
    if (reviewFont.isNotEmpty) {
      final font = FontLoader('TabBarReview')
        ..addFont(File(reviewFont).readAsBytes().then(ByteData.sublistView));
      await font.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    }
  });

  late ValueNotifier<int> selection;
  late List<int> calls;
  const items = [
    AppleTabItem(icon: Icons.home, label: 'Home'),
    AppleTabItem(icon: Icons.explore, label: 'Explore'),
    AppleTabItem(icon: Icons.mail, label: 'Inbox', badgeCount: 12),
    AppleTabItem(icon: Icons.person, label: 'Profile'),
  ];
  setUp(() {
    selection = ValueNotifier(0);
    calls = [];
  });
  tearDown(() => selection.dispose());

  Future<void> mount(
    WidgetTester tester, {
    bool accept = true,
    bool enabled = true,
    bool reduced = false,
    bool solid = false,
    bool dark = false,
    double scale = 1,
    double width = 390,
    TextDirection direction = TextDirection.ltr,
    List<AppleTabItem> tabs = items,
    bool minimized = false,
    VoidCallback? onExpand,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          fontFamily: reviewFont.isEmpty ? null : 'TabBarReview',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
        ),
        home: Directionality(
          textDirection: direction,
          child: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 844),
              textScaler: TextScaler.linear(scale),
              disableAnimations: reduced,
            ),
            child: RepaintBoundary(
              key: const ValueKey('capture'),
              child: ValueListenableBuilder<int>(
                valueListenable: selection,
                builder: (context, index, _) => Scaffold(
                  extendBody: true,
                  body: ListView(
                    children: [
                      for (var row = 0; row < 16; row++)
                        Container(
                          height: 100,
                          color: row.isEven
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                          alignment: Alignment.center,
                          child: Text('Page $index · row $row'),
                        ),
                    ],
                  ),
                  bottomNavigationBar: AppleTabBar(
                    items: tabs,
                    selectedIndex: index,
                    onSelected: enabled
                        ? (value) {
                            calls.add(value);
                            if (accept) selection.value = value;
                          }
                        : null,
                    reduceTransparency: solid,
                    minimized: minimized,
                    onExpand: onExpand,
                    badgeLabel: (count) => '$count unread',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    const output = String.fromEnvironment('TAB_BAR_ARTIFACT_DIR');
    if (output.isEmpty) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('capture')),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await Directory(output).create(recursive: true);
      await File('$output/$name.png').writeAsBytes(bytes.buffer.asUint8List());
      image.dispose();
    });
  }

  Finder tab(String label) => find.text(label);
  Finder getPill() => find.byWidgetPredicate(
    (w) => w is Positioned && w.left != null && w.width != null,
  );
  Rect pillRect(WidgetTester tester) => tester.getRect(getPill());

  testWidgets(
    'drag and hold preview; release commits once and keeps semantics honest',
    (tester) async {
      await mount(tester);
      final gesture = await tester.startGesture(tester.getCenter(tab('Home')));
      await gesture.moveTo(tester.getCenter(tab('Profile')));
      await tester.pump(const Duration(seconds: 2));
      expect(calls, isEmpty);
      expect(selection.value, 0);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Home'))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        ui.Tristate.isTrue,
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Profile'))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        ui.Tristate.isFalse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, [3]);
      expect(selection.value, 3);
    },
  );

  testWidgets('cancel and vertical dismissal never navigate', (tester) async {
    await mount(tester);
    final gesture = await tester.startGesture(tester.getCenter(tab('Home')));
    await gesture.moveTo(tester.getCenter(tab('Inbox')));
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
    expect(
      pillRect(tester).center.dx,
      closeTo(tester.getCenter(tab('Home')).dx, .1),
    );
    await tester.drag(tab('Home'), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
  });

  testWidgets('off-center grab stays under the same finger point', (
    tester,
  ) async {
    await mount(tester);
    final before = pillRect(tester);
    final gesture = await tester.startGesture(
      before.center + const Offset(25, 0),
    );
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    expect(pillRect(tester).center.dx - before.center.dx, closeTo(100, .1));
    await gesture.cancel();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'rapid reversal and re-grab continue from the displayed capsule',
    (tester) async {
      await mount(tester);
      await tester.tap(tab('Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final before = pillRect(tester);
      selection.value = 1;
      await tester.pump();
      expect(pillRect(tester).left, closeTo(before.left, .1));
      expect(pillRect(tester).right, closeTo(before.right, .1));
      final gesture = await tester.startGesture(
        tester.getCenter(tab('Explore')),
      );
      final grabbed = pillRect(tester);
      await tester.pump(const Duration(milliseconds: 80));
      expect(pillRect(tester).left, closeTo(grabbed.left, .1));
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      expect(pillRect(tester).center.dx - grabbed.center.dx, closeTo(30, .1));
      await gesture.cancel();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('parent rejection and external navigation cancel stale preview', (
    tester,
  ) async {
    await mount(tester, accept: false);
    await tester.drag(tab('Home'), const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(calls, [3]);
    expect(selection.value, 0);
    expect(
      pillRect(tester).center.dx,
      closeTo(tester.getCenter(tab('Home')).dx, .1),
    );
    calls.clear();
    final gesture = await tester.startGesture(tester.getCenter(tab('Home')));
    await gesture.moveTo(tester.getCenter(tab('Profile')));
    await tester.pump();
    selection.value = 1;
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
    expect(selection.value, 1);
  });

  testWidgets(
    'disabled targets, disabled bar, and RTL honor the same routing',
    (tester) async {
      await mount(
        tester,
        tabs: [
          items[0],
          items[1],
          items[2],
          const AppleTabItem(
            icon: Icons.person,
            label: 'Profile',
            enabled: false,
          ),
        ],
      );
      await tester.tap(tab('Profile'));
      await tester.drag(tab('Home'), const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await mount(tester, enabled: false);
      await tester.tap(tab('Explore'));
      await tester.drag(tab('Home'), const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await mount(tester, direction: TextDirection.rtl);
      final gesture = await tester.startGesture(tester.getCenter(tab('Home')));
      await gesture.moveTo(tester.getCenter(tab('Profile')));
      await tester.pump();
      expect(calls, isEmpty);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, [3]);
    },
  );

  testWidgets(
    'keyboard and accessibility activate real buttons with badge context',
    (tester) async {
      await mount(tester, reduced: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, [1]);
      final inbox = tester.getSemantics(
        find.bySemanticsLabel('Inbox, 12 unread'),
      );
      inbox.owner!.performAction(inbox.id, ui.SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(calls, [1, 2]);
      expect(
        pillRect(tester).center.dx,
        closeTo(tester.getCenter(tab('Inbox')).dx, .1),
      );
    },
  );

  testWidgets('minimized capsule expands without committing a route', (
    tester,
  ) async {
    var expansions = 0;
    await mount(tester, minimized: true, onExpand: () => expansions++);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(expansions, 1);
    expect(calls, isEmpty);
  });

  testWidgets(
    'five tabs, two tabs, theme, large text, and solid mode render cleanly',
    (tester) async {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 3.0]) {
          await mount(
            tester,
            dark: dark,
            scale: scale,
            width: scale > 1 ? 320 : 390,
            solid: scale > 1,
            tabs: [
              ...items,
              const AppleTabItem(icon: Icons.settings, label: 'Settings'),
            ],
          );
          expect(tester.takeException(), isNull);
          await capture(tester, '${dark ? 'dark' : 'light'}-${scale.toInt()}x');
          if (scale == 1) {
            final gesture = await tester.startGesture(
              tester.getCenter(tab('Home')),
            );
            await gesture.moveBy(const Offset(115, 0));
            await tester.pump(const Duration(seconds: 1));
            await capture(tester, '${dark ? 'dark' : 'light'}-held');
            await gesture.cancel();
            await tester.pumpAndSettle();
            await tester.tap(tab('Profile'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 140));
            await capture(tester, '${dark ? 'dark' : 'light'}-stretch');
            selection.value = 0;
            await tester.pumpAndSettle();
          }
        }
      }
      await mount(tester, tabs: items.take(2).toList());
      await tester.tap(tab('Explore'));
      await tester.pumpAndSettle();
      expect(selection.value, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'demo user scroll minimizes, expansion restores every destination',
    (tester) async {
      await tester.pumpWidget(const TabBarExample());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('首页, 展开导航'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('首页, 展开导航'));
      await tester.pumpAndSettle();
      expect(find.text('发现'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scroll policy ignores nested, horizontal, and programmatic updates',
    (tester) async {
      await mount(tester);
      ScrollUpdateNotification event({
        AxisDirection axis = AxisDirection.down,
        bool user = true,
        double delta = 10,
        double offset = 100,
        int depth = 0,
      }) => ScrollUpdateNotification(
        metrics: FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 1000,
          pixels: offset,
          viewportDimension: 600,
          axisDirection: axis,
          devicePixelRatio: 1,
        ),
        context: tester.element(find.byType(AppleTabBar)),
        scrollDelta: delta,
        depth: depth,
        dragDetails: user
            ? DragUpdateDetails(globalPosition: Offset.zero)
            : null,
      );
      expect(appleTabBarMinimizedFor(event()), isTrue);
      expect(appleTabBarMinimizedFor(event(delta: -10)), isFalse);
      expect(appleTabBarMinimizedFor(event(offset: 0)), isFalse);
      expect(appleTabBarMinimizedFor(event(delta: 2)), isNull);
      expect(appleTabBarMinimizedFor(event(user: false)), isNull);
      expect(appleTabBarMinimizedFor(event(axis: AxisDirection.right)), isNull);
      final nested = event(depth: 1);
      expect(appleTabBarMinimizedFor(nested), isNull);
    },
  );
}
