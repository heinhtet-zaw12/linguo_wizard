import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../widgets/language_step.dart';
import '../widgets/cefr_step.dart';
import '../widgets/goal_step.dart';

/// Three-step onboarding: language → CEFR level → goal.
///
/// Saves selections to SharedPreferences and navigates to scenario selection.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onComplete() async {
    final vm = ref.read(onboardingProvider.notifier);
    await vm.saveAndComplete();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final vm = ref.read(onboardingProvider.notifier);

    // Sync page controller with state
    ref.listen<OnboardingState>(onboardingProvider, (prev, next) {
      if (prev?.currentPage != next.currentPage) {
        _goToPage(next.currentPage);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Top: progress dots ───
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _PageIndicator(
                  currentPage: state.currentPage,
                  totalPages: 3,
                ),
              ),

              // ─── Middle: page view ───
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    // Only update state if user somehow triggers a page change
                  },
                  children: [
                    LanguageStep(
                      selectedLanguage: state.selectedLanguage,
                      onSelected: vm.setLanguage,
                    ),
                    CefrStep(
                      selectedLevel: state.selectedCefrLevel,
                      onSelected: vm.setCefrLevel,
                    ),
                    GoalStep(
                      selectedGoal: state.selectedGoal,
                      onSelected: vm.setGoal,
                    ),
                  ],
                ),
              ),

              // ─── Bottom: navigation buttons ───
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Row(
                  children: [
                    if (state.currentPage > 0)
                      TextButton(
                        onPressed: () {
                          vm.previousPage();
                        },
                        child: Text(
                          'Back',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),
                    const Spacer(),
                    _NextButton(
                      label: state.isLastPage ? 'Start Learning' : 'Next',
                      isEnabled: state.canProceed,
                      onPressed: state.isLastPage ? _onComplete : vm.nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryPink : AppColors.primaryPinkLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.label,
    required this.isEnabled,
    required this.onPressed,
  });

  final String label;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          disabledBackgroundColor: AppColors.primaryPinkLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: isEnabled ? 4 : 0,
          shadowColor: AppColors.shadowPink,
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
