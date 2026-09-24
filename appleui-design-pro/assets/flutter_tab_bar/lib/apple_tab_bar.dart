import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Navigation data only. The host owns pages, routes, and accepted selection.
@immutable
class AppleTabItem {
  const AppleTabItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount = 0,
    this.enabled = true,
  }) : assert(label != ''),
       assert(badgeCount >= 0);

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int badgeCount;
  final bool enabled;
}

/// Optional scroll-to-minimize policy. Return null when no change is requested.
/// Listen around the active vertical page; this never consumes notifications.
/// ponytail: only direct user drags change state; ballistic/programmatic scrolls
/// are ignored so restoring a page cannot unexpectedly collapse navigation.
bool? appleTabBarMinimizedFor(ScrollNotification event) {
  if (event.depth != 0 ||
      event.metrics.axis != Axis.vertical ||
      event is! ScrollUpdateNotification ||
      event.dragDetails == null) {
    return null;
  }
  final delta = event.scrollDelta ?? 0;
  if (event.metrics.pixels <= 0 || delta < -4) return false;
  if (event.metrics.pixels > 40 && delta > 4) return true;
  return null;
}

/// A Flutter blur/material approximation, not native Liquid Glass or refraction.
/// Copy this file into an existing Flutter app. No plugin or global state needed.
///
/// SafeArea is owned here. Use Scaffold.extendBody and leave enough scroll padding
/// below content. [onSelected] is called on activation/release, never while moving.
class AppleTabBar extends StatefulWidget {
  const AppleTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.minimized = false,
    this.onExpand,
    this.expandLabel = 'Expand navigation',
    this.badgeLabel,
    this.reduceTransparency = false,
    this.tint,
    this.motionDuration = const Duration(milliseconds: 380),
  }) : assert(items.length >= 2 && items.length <= 5),
       assert(selectedIndex >= 0 && selectedIndex < items.length),
       assert(!minimized || onExpand != null);

  final List<AppleTabItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final bool minimized;
  final VoidCallback? onExpand;
  final String expandLabel;

  /// Localize e.g. (count) => '$count unread'. Visual counts cap at 99+.
  final String Function(int count)? badgeLabel;

  /// Supply from a platform accessibility bridge or the app's own preference.
  /// Flutter MediaQuery has no cross-platform Reduce Transparency field.
  final bool reduceTransparency;
  final Color? tint;
  final Duration motionDuration;

  @override
  State<AppleTabBar> createState() => _AppleTabBarState();
}

class _AppleTabBarState extends State<AppleTabBar>
    with TickerProviderStateMixin {
  late final _motion = AnimationController(vsync: this, value: 1);
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 180),
  );
  Rect? _from;
  Rect? _to;
  Rect? _dragRect;
  Rect? _grabRect;
  int? _pointer;
  int _generation = 0;
  double _downX = 0;
  double _width = 0;
  double _downWidth = 0;
  bool _dragging = false;
  bool _reduceMotion = false;
  TextDirection _direction = TextDirection.ltr;

  double get _activity => _reduceMotion
      ? 0
      : math.max(_press.value, math.sin(math.pi * _motion.value));

  bool get _enabled => widget.onSelected != null;
  double _visualSlot(int index) =>
      (_direction == TextDirection.rtl
              ? widget.items.length - 1 - index
              : index)
          .toDouble();
  Rect get _target => Rect.fromLTWH(_visualSlot(widget.selectedIndex), 0, 1, 1);
  double get _slotWidth => (_width - 16) / widget.items.length;

  // Both edges use RAW time once. On interruption start from the displayed rect.
  Rect get _display {
    if (_dragRect != null) return _dragRect!;
    final from = _from ?? _target;
    final to = _to ?? _target;
    final t = _motion.value;
    final leading = Curves.easeOutCubic.transform(t);
    final trailing = Curves.easeInCubic.transform(t);
    final rightward = to.center.dx >= from.center.dx;
    final left = lerpDouble(
      from.left,
      to.left,
      rightward ? trailing : leading,
    )!;
    final right = lerpDouble(
      from.right,
      to.right,
      rightward ? leading : trailing,
    )!;
    return Rect.fromLTRB(left, 0, right, 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final direction = Directionality.of(context);
    final reduceMotion =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (direction != _direction || reduceMotion != _reduceMotion) {
      _direction = direction;
      _reduceMotion = reduceMotion;
      _reset();
    }
  }

  @override
  void didUpdateWidget(AppleTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.minimized != widget.minimized ||
        oldWidget.onSelected != null && !_enabled) {
      _reset();
    } else if (oldWidget.selectedIndex != widget.selectedIndex ||
        !_sameEnabled(oldWidget.items, widget.items)) {
      _pointer = null;
      _dragging = false;
      _generation++;
      _press.reverse();
      _settle();
    }
  }

  bool _sameEnabled(List<AppleTabItem> a, List<AppleTabItem> b) =>
      List.generate(
        a.length,
        (i) => a[i].enabled == b[i].enabled,
      ).every((same) => same);

  void _reset() {
    _generation++;
    _pointer = null;
    _dragging = false;
    _dragRect = null;
    _grabRect = null;
    _from = _to = _target;
    _motion.stop();
    _motion.value = 1;
    _press.value = 0;
  }

  void _settle() {
    final start = _display;
    _dragRect = null;
    _from = start;
    _to = _target;
    _motion.duration = widget.motionDuration;
    if (_reduceMotion ||
        widget.motionDuration == Duration.zero ||
        start == _to) {
      _motion.value = 1;
    } else {
      _motion.forward(from: 0);
    }
  }

  void _activate(int index) {
    if (!_enabled || !widget.items[index].enabled) {
      setState(_settle);
      return;
    }
    widget.onSelected!(index);
    final generation = ++_generation;
    // Reconcile with the parent's accepted value, including rejected navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) setState(_settle);
    });
  }

  void _down(PointerDownEvent event) {
    if (!_enabled ||
        widget.minimized ||
        _pointer != null ||
        event.buttons != kPrimaryButton)
      return;
    _generation++;
    _grabRect = _display;
    _from = _to = _grabRect;
    _motion.stop();
    _motion.value = 1;
    _pointer = event.pointer;
    _downX = event.localPosition.dx;
    _downWidth = _width;
    if (!_reduceMotion) _press.forward();
  }

  void _up(PointerEvent event) {
    if (_pointer != event.pointer) return;
    _pointer = null;
    _press.reverse();
    final generation = _generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) {
        setState(() {
          _dragging = false;
          _settle();
        });
      }
    });
  }

  void _cancel() {
    _generation++;
    _pointer = null;
    _press.reverse();
    setState(() {
      _dragging = false;
      _settle();
    });
  }

  void _move(DragUpdateDetails details) {
    if (!_dragging || _grabRect == null) return;
    if (_width != _downWidth) {
      _cancel();
      return;
    }
    if (_dragRect == null &&
        (details.localPosition.dx - _downX).abs() <= kTouchSlop)
      return;
    final center =
        (_grabRect!.center.dx +
                (details.localPosition.dx - _downX) / _slotWidth)
            .clamp(0.5, widget.items.length - 0.5);
    setState(() {
      _dragRect = _grabRect!.shift(Offset(center - _grabRect!.center.dx, 0));
    });
  }

  void _end(DragEndDetails details) {
    if (!_dragging) return;
    if (_dragRect == null) {
      _cancel();
      return;
    }
    _dragging = false;
    if (_width != _downWidth) {
      _cancel();
      return;
    }
    final slot = (_display.center.dx - 0.5).round().clamp(
      0,
      widget.items.length - 1,
    );
    final index = _direction == TextDirection.rtl
        ? widget.items.length - 1 - slot
        : slot;
    _activate(index);
  }

  @override
  void dispose() {
    _motion.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final solid =
        widget.reduceTransparency || MediaQuery.highContrastOf(context);
    final height = math.max(
      76.0,
      48 + 2.2 * MediaQuery.textScalerOf(context).scale(11),
    );
    final accent = widget.tint ?? scheme.primary;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          assert(
            constraints.hasBoundedWidth,
            'AppleTabBar needs a bounded width.',
          );
          _width = constraints.maxWidth;
          return AnimatedBuilder(
            animation: Listenable.merge([_motion, _press]),
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -1.5 * _activity),
              transformHitTests: false,
              child: child,
            ),
            child: SizedBox(
              height: height,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: AnimatedContainer(
                  // Text scaling changes height immediately; only width should morph.
                  key: ValueKey(height),
                  duration: _reduceMotion
                      ? Duration.zero
                      : widget.motionDuration,
                  curve: Curves.easeOutCubic,
                  width: widget.minimized ? math.min(_width, 144.0) : _width,
                  height: height,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_motion, _press]),
                    builder: (context, _) {
                      Widget surface = DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(
                            alpha: solid
                                ? 1
                                : scheme.brightness == Brightness.dark
                                ? .82
                                : .78,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: scheme.outlineVariant.withValues(
                              alpha: solid ? 1 : .55,
                            ),
                          ),
                        ),
                        child: widget.minimized
                            ? _collapsed(accent)
                            : OverflowBox(
                                // Expansion clips a full-sized row instead of squeezing hit targets.
                                alignment: AlignmentDirectional.centerStart,
                                minWidth: _width,
                                maxWidth: _width,
                                child: _expanded(height, accent, scheme),
                              ),
                      );
                      if (!solid) {
                        surface = BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: surface,
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: surface,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _collapsed(Color accent) {
    final item = widget.items[widget.selectedIndex];
    final badge = item.badgeCount > 0
        ? ', ${widget.badgeLabel?.call(item.badgeCount) ?? item.badgeCount}'
        : '';
    return Semantics(
      button: true,
      label: '${item.label}$badge, ${widget.expandLabel}',
      onTap: widget.onExpand,
      child: ExcludeSemantics(
        child: TextButton(
          onPressed: widget.onExpand,
          style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(item, true, accent),
              const SizedBox(width: 8),
              Icon(Icons.unfold_more_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expanded(double height, Color accent, ColorScheme scheme) {
    final rect = _display;
    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: (event) {
        if (_pointer == event.pointer) _cancel();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragStart: _enabled
            ? (_) {
                _dragging = _pointer != null;
              }
            : null,
        onHorizontalDragUpdate: _enabled ? _move : null,
        onHorizontalDragEnd: _enabled ? _end : null,
        onHorizontalDragCancel: _enabled ? _cancel : null,
        child: Stack(
          children: [
            Positioned(
              left: 8 + rect.left * _slotWidth,
              top: 8,
              width: rect.width * _slotWidth,
              height: height - 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(
                    alpha: scheme.brightness == Brightness.dark ? .19 : .10,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  // One edge, using the same rect/radius as its fill. No sampled icon copies.
                  border: Border.all(
                    color: accent.withValues(alpha: .12 + .12 * _activity),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    Expanded(child: _item(i, accent, scheme.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon(AppleTabItem item, bool selected, Color color) => Badge(
    isLabelVisible: item.badgeCount > 0,
    // Auxiliary count stays compact; its full value is in the tab's semantic label.
    label: Text(
      item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
      textScaler: TextScaler.noScaling,
    ),
    child: Icon(
      selected ? item.selectedIcon ?? item.icon : item.icon,
      size: 25,
      color: color,
    ),
  );

  Widget _item(int index, Color accent, Color foreground) {
    final item = widget.items[index];
    final selected = index == widget.selectedIndex;
    final enabled = _enabled && item.enabled;
    final color = (selected ? accent : foreground).withValues(
      alpha: enabled ? 1 : .38,
    );
    final label = item.badgeCount > 0
        ? '${item.label}, ${widget.badgeLabel?.call(item.badgeCount) ?? item.badgeCount}'
        : item.label;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      onTap: enabled ? () => _activate(index) : null,
      child: ExcludeSemantics(
        child: TextButton(
          onPressed: enabled ? () => _activate(index) : null,
          style:
              TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                minimumSize: const Size(44, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                foregroundColor: color,
                splashFactory: NoSplash.splashFactory,
              ).copyWith(
                overlayColor: WidgetStateProperty.resolveWith(
                  (states) =>
                      states.contains(WidgetState.focused) ||
                          states.contains(WidgetState.hovered)
                      ? accent.withValues(alpha: .14)
                      : Colors.transparent,
                ),
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(item, selected, color),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
