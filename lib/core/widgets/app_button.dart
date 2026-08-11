import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Unified button component with multiple variants.
enum AppButtonVariant { primary, secondary, compact, ghost }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.97);
  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final button = switch (widget.variant) {
      AppButtonVariant.primary => _buildPrimary(),
      AppButtonVariant.secondary => _buildSecondary(),
      AppButtonVariant.compact => _buildCompact(),
      AppButtonVariant.ghost => _buildGhost(),
    };

    final isEnabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: isEnabled ? _onTapDown : null,
        onTapUp: isEnabled ? _onTapUp : null,
        onTapCancel: isEnabled ? _onTapCancel : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.4,
            child: button,
          ),
        ),
      ),
    );
  }

  /// Wraps content so it fills available width when constrained
  /// but sizes to content when placed in an unconstrained layout.
  Widget _fillOrContent(Widget child) {
    return Align(
      alignment: Alignment.center,
      widthFactor: 1.0,
      child: child,
    );
  }

  Widget _buildPrimary() {
    return _fillOrContent(
      Container(
        height: AppSizing.buttonHeight,
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.glowBlue,
        ),
        child: Center(child: _buildChild(AppColors.textOnAccent)),
      ),
    );
  }

  Widget _buildSecondary() {
    return _fillOrContent(
      Container(
        height: AppSizing.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.accentCyan, width: 1),
        ),
        child: Center(child: _buildChild(AppColors.accentCyan)),
      ),
    );
  }

  /// Compact filled variant — same gradient as primary, shorter height,
  /// no glow shadow. For tight spaces like onboarding nav bars.
  Widget _buildCompact() {
    return _fillOrContent(
      Container(
        height: AppSizing.buttonHeightSm, // 40px
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: AppRadius.md,
        ),
        child: Center(child: _buildChild(AppColors.textOnAccent)),
      ),
    );
  }

  Widget _buildGhost() {
    return _fillOrContent(
      SizedBox(
        height: AppSizing.buttonHeight,
        child: Center(child: _buildChild(AppColors.accentCyan)),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }

    final textStyle = AppTextStyles.labelLarge(color: color);

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: AppSizing.iconLg, color: color),
          const SizedBox(width: AppSpacing.s2),
          Text(widget.label, style: textStyle),
        ],
      );
    }

    return Text(widget.label, style: textStyle);
  }
}
