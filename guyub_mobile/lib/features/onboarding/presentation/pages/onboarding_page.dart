import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../config/routes/route_names.dart';

/// Onboarding Data Model
class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Onboarding Slides Data
const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    title: 'Selamat Datang di Guyub',
    description:
        'Platform modern untuk mengelola dan merayakan silsilah keluarga Anda dengan mudah dan indah.',
    icon: Icons.waving_hand_rounded,
  ),
  OnboardingSlide(
    title: 'Kelola Pohon Keluarga',
    description:
        'Buat dan kelola silsilah keluarga Anda dengan antarmuka yang intuitif. Tambahkan anggota keluarga, hubungan, dan riwayat dengan mudah.',
    icon: Icons.account_tree_rounded,
  ),
  OnboardingSlide(
    title: 'Atur Acara Keluarga',
    description:
        'Rencanakan dan kelola acara keluarga seperti ulang tahun, reuni, atau perayaan penting lainnya dengan fitur kalender terintegrasi.',
    icon: Icons.event_available_rounded,
  ),
  OnboardingSlide(
    title: 'Offline Support',
    description:
        'Tetap bisa mengakses dan mengelola data keluarga Anda bahkan tanpa koneksi internet. Semua data tersimpan secara lokal.',
    icon: Icons.offline_bolt_rounded,
  ),
];

/// Onboarding Page
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingComplete, true);
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  void _nextPage() {
    if (_currentPage < onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.8),
                  ),
                  child: const Text(
                    'Lewati',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: onboardingSlides.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlideWidget(slide: onboardingSlides[index]);
                },
              ),
            ),

            // Bottom Section
            Container(
              padding: AppSpacing.paddingXL,
              child: Column(
                children: [
                  // Page Indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingSlides.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withValues(alpha: 0.3),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),

                  AppSpacing.verticalLG,

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusMd,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == onboardingSlides.length - 1
                            ? 'Mulai Sekarang'
                            : 'Selanjutnya',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onboarding Slide Widget
class _OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;

  const _OnboardingSlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: Colors.white),
          ),

          AppSpacing.verticalXL,

          // Title
          Text(
            slide.title,
            style: AppTypography.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalLG,

          // Description
          Text(
            slide.description,
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
