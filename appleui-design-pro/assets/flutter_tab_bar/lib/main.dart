import 'package:flutter/material.dart';

import 'apple_tab_bar.dart';

void main() => runApp(const TabBarExample());

class TabBarExample extends StatefulWidget {
  const TabBarExample({super.key});

  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> {
  int _selected = 0;
  bool _minimized = false;
  ThemeMode _theme = ThemeMode.system;
  final _scrollControllers = List.generate(4, (_) => ScrollController());
  static const _items = [
    AppleTabItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: '首页',
    ),
    AppleTabItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      label: '发现',
    ),
    AppleTabItem(
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      label: '通知',
      badgeCount: 3,
    ),
    AppleTabItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: '我的',
    ),
  ];

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: _theme,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6558B5)),
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFABA2F5),
        brightness: Brightness.dark,
      ),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(_items[_selected].label),
          actions: [
            IconButton(
              tooltip: '切换明暗外观',
              onPressed: () => setState(() {
                _theme = Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              }),
              icon: const Icon(Icons.brightness_6_outlined),
            ),
          ],
        ),
        body: IndexedStack(
          index: _selected,
          children: [
            for (var page = 0; page < _items.length; page++)
              TickerMode(
                enabled: page == _selected,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (event) {
                    if (page != _selected) return false;
                    final minimized = appleTabBarMinimizedFor(event);
                    if (minimized != null && minimized != _minimized) {
                      setState(() => _minimized = minimized);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollControllers[page],
                    // extendBody gives the body a bottom inset equal to the nav area.
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      MediaQuery.paddingOf(context).bottom + 160,
                    ),
                    itemCount: 24,
                    itemBuilder: (context, row) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer
                            .withValues(alpha: row.isEven ? .65 : .3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row == 0
                                ? '轻触切换 · 拖动预览'
                                : '${_items[page].label} ${row + 1}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const Text('页面在松手后切换。向下浏览收起导航，向上浏览或轻触小胶囊展开。'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: AppleTabBar(
          items: _items,
          selectedIndex: _selected,
          onSelected: (index) => setState(() {
            _selected = index;
            _minimized = false;
          }),
          minimized: _minimized,
          onExpand: () => setState(() => _minimized = false),
          expandLabel: '展开导航',
          badgeLabel: (count) => '$count 条未读',
        ),
      ),
    ),
  );
}
