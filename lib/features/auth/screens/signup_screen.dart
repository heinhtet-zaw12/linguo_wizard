import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Sign-up screen with name, email, password, and Google sign-up.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(authProvider.notifier);
    await vm.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.errorMessage != null) {
      _showError(state.errorMessage!);
    } else {
      context.go('/home');
    }
  }

  Future<void> _onGoogleSignUp() async {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─── Title ───
                    Text(
                      'Create Account',
                      style: GoogleFonts.fredoka(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your learning journey',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── Inline Error Banner ───
                    if (authState.errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentCoral.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentCoral.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.accentCoral,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentCoral,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ref.read(authProvider.notifier).clearError(),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.accentCoral,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ─── Name Field ───
                    AppTextField(
                      controller: _nameController,
                      label: 'Display Name',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                          color: AppColors.textMuted,
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
                    const SizedBox(height: 24),

                    // ─── Sign Up Button ───
                    AppButton(
                      label: 'Sign Up',
                      isLoading: authState.isLoading,
                      onPressed: _onSignUp,
                    ),
                    const SizedBox(height: 20),

                    // ─── Divider ───
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.primaryPinkLight)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.primaryPinkLight)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── Google Sign-Up ───
                    AppButton(
                      label: 'Sign up with Google',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.g_mobiledata_rounded,
                      isLoading: authState.isLoading,
                      onPressed: _onGoogleSignUp,
                    ),
                    const SizedBox(height: 24),

                    // ─── Sign In Link ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPinkDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
