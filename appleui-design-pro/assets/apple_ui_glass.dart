// Flutter SDK with ImageFilter.shader and isShaderFilterSupported.
// pubspec: flutter: shaders: [assets/apple_ui_lens.frag]
// Pass a loaded FragmentProgram; this widget owns its per-surface FragmentShader.
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

class AppleUIGlass extends StatefulWidget {
  const AppleUIGlass({
    super.key,
    required this.child,
    this.program,
    this.reduceTransparency = false,
    this.surfaceColor,
    this.radiusFraction = 0.18,
    this.bandFraction = 0.18,
    this.strengthFraction = 0.025,
  });

  final Widget child;
  final ui.FragmentProgram? program;
  // Supply a live platform/app preference; accessibleNavigation is not this flag.
  final bool reduceTransparency;
  // Optional resolved tint. Validate foreground contrast over actual backgrounds.
  final Color? surfaceColor;
  final double radiusFraction;
  final double bandFraction;
  final double strengthFraction;

  @override
  State<AppleUIGlass> createState() => _AppleUIGlassState();
}

class _AppleUIGlassState extends State<AppleUIGlass> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _shader = widget.program?.fragmentShader();
  }

  @override
  void didUpdateWidget(AppleUIGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.program != oldWidget.program) {
      _shader?.dispose();
      _shader = widget.program?.fragmentShader();
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opaque =
        widget.reduceTransparency || MediaQuery.highContrastOf(context);
    final background = CupertinoColors.systemBackground.resolveFrom(context);
    final border = CupertinoColors.separator.resolveFrom(context);
    final lens = LayoutBuilder(
      builder: (context, constraints) {
        // Positioned.fill below supplies the content's actual laid-out dimensions.
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return ColoredBox(color: background);
        }
        final extent = constraints.biggest.shortestSide;
        final fraction = widget.radiusFraction.isFinite
            ? widget.radiusFraction.clamp(0.0, 0.5).toDouble()
            : 0.18;
        final radius = BorderRadius.circular(extent * fraction);
        Widget surface = DecoratedBox(
          decoration: BoxDecoration(
            color: opaque
                ? background
                : widget.surfaceColor ?? background.withValues(alpha: 0.72),
            borderRadius: radius,
            border: Border.all(
              color: opaque
                  ? CupertinoColors.label.resolveFrom(context)
                  : border,
            ),
          ),
          child: const SizedBox.expand(),
        );
        if (!opaque) {
          final shader = _shader;
          ui.ImageFilter filter;
          if (shader != null && ui.ImageFilter.isShaderFilterSupported) {
            // Engine owns float 0,1 and texture sampler 0.
            shader.setFloat(2, fraction);
            shader.setFloat(
              3,
              widget.bandFraction.isFinite
                  ? widget.bandFraction.clamp(0.001, 0.5).toDouble()
                  : 0.18,
            );
            shader.setFloat(
              4,
              widget.strengthFraction.isFinite
                  ? widget.strengthFraction.clamp(0.0, 0.1).toDouble()
                  : 0.025,
            );
            filter = ui.ImageFilter.shader(shader);
          } else {
            // Explicit material fallback: this branch blurs, it does not refract.
            filter = ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12);
          }
          surface = BackdropFilter(filter: filter, child: surface);
        }
        return ClipRRect(borderRadius: radius, child: surface);
      },
    );
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(child: lens),
        widget.child,
      ],
    );
  }
}

// Keep the real control and its semantics above the filtered background:
// SizedBox(width: 240, child: AppleUIGlass(program: program,
//   child: CupertinoButton(onPressed: save, child: const Text('Save'))));
// The foreground sets height naturally; use padding/reflow for larger content.
// Default tint prioritizes legibility; tune surfaceColor after contrast checks.
// This is a static lens: reduced-motion behavior is owned by any added animation.
