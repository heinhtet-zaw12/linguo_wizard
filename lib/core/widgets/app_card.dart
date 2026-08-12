import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';

/// Glass-style card container with semi-transparent background.
/// Optional [onTap] adds scale + opacity press feedback.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.glowColor,
    this.elevation = 1,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? glowColor;
  final int elevation;
  final VoidCallback? onTap;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.98).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.98, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.85), weight: 50),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    widget.onTap!();
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final shadows = switch (widget.elevation) {
      2 => AppShadows.elevation2,
      3 => AppShadows.elevation3,
      _ => AppShadows.elevation1,
    };

    final radius = widget.borderRadius ?? AppRadius.md;

    final card = Container(
      padding: widget.padding ?? AppSpacing.all4,
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: radius,
        border: Border.all(
          color: widget.glowColor ?? AppColors.borderSubtle,
          width: 0.5,
        ),
        boxShadow: [
          ...shadows,
          if (widget.glowColor != null)
            BoxShadow(
              color: widget.glowColor!,
              blurRadius: 20,
              spreadRadius: -2,
            ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: Opacity(
          opacity: _opacityAnim.value,
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      ),
    );
  }
}
