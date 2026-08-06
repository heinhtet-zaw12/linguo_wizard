import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Login screen with email/password, Google sign-in, and guest access.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(authProvider.notifier);
    await vm.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.errorMessage != null) {
      _showError(state.errorMessage!);
    } else {
      context.go('/home');
    }
  }

  Future<void> _onGoogleSignIn() async {
    final vm = ref.read(authProvider.notifier);
    await vm.signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.errorMessage != null) {
      _showError(state.errorMessage!);
    } else {
      context.go('/home');
    }
  }

  Future<void> _onGuestSignIn() async {
    final vm = ref.read(authProvider.notifier);
    await vm.signInAsGuest();
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.errorMessage != null) {
      _showError(state.errorMessage!);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── Title ───
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue learning',
                        style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),

                      // ─── Inline Error Banner ───
                      if (authState.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: AppTextStyles.labelMedium(color: AppColors.danger),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref.read(authProvider.notifier).clearError(),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.danger,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ─── Email Field ───
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ─── Password Field ───
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // ─── Forgot Password ───
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.labelMedium(color: AppColors.accentCyan),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Sign In Button ───
                      AppButton(
                        label: 'Sign In',
                        isLoading: authState.isLoading,
                        onPressed: _onSignIn,
                      ),
                      const SizedBox(height: 20),

                      // ─── Divider ───
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.borderSubtle)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.borderSubtle)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ─── Google Sign-In ───
                      AppButton(
                        label: 'Sign in with Google',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.g_mobiledata_rounded,
                        isLoading: authState.isLoading,
                        onPressed: _onGoogleSignIn,
                      ),
                      const SizedBox(height: 16),

                      // ─── Guest Sign-In ───
                      AppButton(
                        label: 'Continue as Guest',
                        variant: AppButtonVariant.ghost,
                        isLoading: authState.isLoading,
                        onPressed: _onGuestSignIn,
                      ),
                      const SizedBox(height: 8),

                      // ─── Sign Up Link ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.labelMedium(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.labelMedium(color: AppColors.accentCyan),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
