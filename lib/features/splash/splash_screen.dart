import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../../core/theme/app_text_styles.dart';

/// Animated splash screen — futuristic dark theme.
///
/// Handles navigation internally based on auth state and onboarding status:
///   - Not authenticated → /login
///   - Guest/authenticated without onboarding → /onboarding
///   - Guest/authenticated with onboarding done → /home
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _bobCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    _glowOpacity = Tween<double>(begin: 0.0, end: 0.55).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _exitOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _bobCtrl.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _sparkleCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    await _exitCtrl.forward();

    // Determine navigation target based on auth + onboarding state
    await _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    if (!mounted) return;

    // Navigate to home — GoRouter's redirect handles auth/onboarding routing.
    context.go('/home');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _sparkleCtrl.dispose();
    _bobCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GradientBackground(
        child: AnimatedBuilder(
          animation: _exitCtrl,
          builder: (context, _) {
            return Stack(
              children: [
                // 1 ── Radial glow behind logo
                _RadialGlow(opacity: _glowOpacity, size: size),

                // 2 ── Center column: logo + text
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedLogo(
                        scale: _logoScale,
                        bob: _bobCtrl,
                        size: size,
                      ),
                      const SizedBox(height: 28),
                      _AppName(opacity: _titleOpacity, slide: _titleSlide),
                      const SizedBox(height: 10),
                      _Tagline(opacity: _taglineOpacity, slide: _taglineSlide),
                    ],
                  ),
                ),

                // 3 ── Sparkle particles
                _SparkleBurst(controller: _sparkleCtrl, size: size),

                // 4 ── Floating decorative orbs
                _FloatingOrbs(bob: _bobCtrl),

                // 5 ── Dark exit overlay
                if (_exitCtrl.isAnimating || _exitCtrl.isCompleted)
                  IgnorePointer(
                    child: Opacity(
                      opacity: _exitOpacity.value,
                      child: Container(color: AppColors.surfaceBase),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Sub-widgets
// ═══════════════════════════════════════════════════════════════

class _RadialGlow extends StatelessWidget {
  const _RadialGlow({required this.opacity, required this.size});
  final Animation<double> opacity;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: opacity,
      builder: (context, _) {
        final v = opacity.value;
        return Center(
          child: Container(
            width: size.width * 0.72,
            height: size.width * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentStart.withValues(alpha: v * 0.5),
                  AppColors.accentMid.withValues(alpha: v * 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.scale,
    required this.bob,
    required this.size,
  });
  final Animation<double> scale;
  final AnimationController bob;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scale, bob]),
      builder: (context, _) {
        final bobOffset = math.sin(bob.value * math.pi * 2) * 6;
        return Transform.translate(
          offset: Offset(0, bobOffset),
          child: Transform.scale(
            scale: scale.value,
            child: _ClayShadow(
              child: Image.asset(
                'assets/images/logo.jpeg',
                width: size.width * 0.44,
                height: size.width * 0.44,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClayShadow extends StatelessWidget {
  const _ClayShadow({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.borderGlow,
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x99FFFFFF),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}

class _AppName extends StatelessWidget {
  const _AppName({required this.opacity, required this.slide});
  final Animation<double> opacity;
  final Animation<double> slide;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([opacity, slide]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, slide.value),
          child: Opacity(
            opacity: opacity.value,
            child: Text(
              'Linguo Wizard',
              style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
            ),
          ),
        );
      },
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline({required this.opacity, required this.slide});
  final Animation<double> opacity;
  final Animation<double> slide;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([opacity, slide]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, slide.value),
          child: Opacity(
            opacity: opacity.value,
            child: Text(
              'Speak naturally. Learn magically.',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Sparkle particles
// ═══════════════════════════════════════════════════════════════

class _SparkleBurst extends StatelessWidget {
  const _SparkleBurst({required this.controller, required this.size});
  final AnimationController controller;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            size: size,
            painter: _SparklePainter(progress: controller.value),
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.progress});
  final double progress;

  static const _colors = [
    AppColors.warning,
    AppColors.accentEnd,
    Colors.white,
    AppColors.danger,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const int count = 14;
    final rng = math.Random(42);
    final center = Offset(size.width / 2, size.height * 0.38);

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 + rng.nextDouble() * 0.5;
      final maxRadius = 80.0 + rng.nextDouble() * 60;
      final radius = maxRadius * Curves.easeOut.transform(progress);
      final dx = center.dx + math.cos(angle) * radius;
      final dy = center.dy + math.sin(angle) * radius - 20;

      final dp = (progress - i * 0.02).clamp(0.0, 1.0);
      final opacity = (1.0 - dp).clamp(0.0, 1.0);
      final dotRadius = (3.0 + rng.nextDouble() * 3) * opacity;

      final paint = Paint()
        ..color = _colors[i % 4].withValues(alpha: opacity * 0.85)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
//  Floating accent orbs
// ═══════════════════════════════════════════════════════════════

class _FloatingOrbs extends StatelessWidget {
  const _FloatingOrbs({required this.bob});
  final AnimationController bob;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bob,
      builder: (context, _) {
        final sin = math.sin(bob.value * math.pi * 2);
        final mq = MediaQuery.of(context);
        return Stack(
          children: [
            _orb(
              top: mq.size.height * 0.12 + sin * 8,
              left: mq.size.width * 0.08,
              size: 48,
              color: AppColors.accentEnd.withValues(alpha: 0.35),
            ),
            _orb(
              top: mq.size.height * 0.18 - sin * 6,
              right: mq.size.width * 0.1,
              size: 32,
              color: AppColors.warning.withValues(alpha: 0.25),
            ),
            _orb(
              bottom: mq.size.height * 0.15 + sin * 10,
              left: mq.size.width * 0.14,
              size: 24,
              color: AppColors.danger.withValues(alpha: 0.2),
            ),
            _orb(
              bottom: mq.size.height * 0.2 - sin * 7,
              right: mq.size.width * 0.06,
              size: 40,
              color: AppColors.accentStart.withValues(alpha: 0.18),
            ),
          ],
        );
      },
    );
  }

  Widget _orb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: color, blurRadius: 18, spreadRadius: 4)],
        ),
      ),
    );
  }
}
