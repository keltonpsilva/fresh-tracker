import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../../shared/services/app_preferences_service.dart';

class OnboardingSlide {
  final String title;
  final String subtitle;

  const OnboardingSlide({required this.title, required this.subtitle});
}

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'Waste Less, Save More',
      subtitle:
          'Easily track food in your fridge, reduce waste, and manage your kitchen inventory.',
    ),
    OnboardingSlide(
      title: 'Smart Expiration Tracking',
      subtitle:
          'Get timely notifications about expiring items and never let food go to waste again.',
    ),
    OnboardingSlide(
      title: 'Plan Meals, Save Money',
      subtitle:
          'Create meal plans based on what you have, reduce grocery trips, and save on your food budget.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGetStartedPressed(BuildContext context) {
    if (_currentPage < _slides.length - 1) {
      // Navigate to next slide
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last slide - finish onboarding
      _finishOnboarding(context);
    }
  }

  Future<void> _finishOnboarding(BuildContext context) async {
    // Mark first launch as complete
    await AppPreferencesService.setFirstLaunchComplete();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  void _onSignInPressed(BuildContext context) {
    // Navigate to sign in (for now, same as finish onboarding)
    _finishOnboarding(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF102212)
          : const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area with PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Refrigerator Illustration
                          _buildRefrigeratorIllustration(),

                          const SizedBox(height: 24),

                          // Headline
                          Text(
                            slide.title,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF333333),
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          // Body Text
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              slide.subtitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: isDark
                                    ? Colors.grey[300]
                                    : const Color(0xFF888888),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom section with indicators and buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: _buildPageIndicator(
                          isActive: index == _currentPage,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Get Started / Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _onGetStartedPressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _slides.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sign In Button
                  TextButton(
                    onPressed: () => _onSignInPressed(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.grey[300]
                            : const Color(0xFF888888),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefrigeratorIllustration() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8F6),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Refrigerator illustration placeholder
              // In a real app, you would use an actual image asset here
              // For now, using a simplified version similar to welcome_screen
              _buildRefrigeratorIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefrigeratorIcon() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Floor base
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Refrigerator body
          Positioned(
            bottom: 16,
            child: Container(
              width: 200,
              height: 264,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF9E9E9E), width: 2),
              ),
              child: Stack(
                children: [
                  // Door edge
                  Positioned(
                    right: -10,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB0B0B0),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // Shelves
                  Positioned(
                    top: 40,
                    left: 8,
                    right: 8,
                    child: Container(height: 2, color: const Color(0xFF9E9E9E)),
                  ),
                  Positioned(
                    top: 100,
                    left: 8,
                    right: 8,
                    child: Container(height: 2, color: const Color(0xFF9E9E9E)),
                  ),
                  Positioned(
                    top: 160,
                    left: 8,
                    right: 8,
                    child: Container(height: 2, color: const Color(0xFF9E9E9E)),
                  ),

                  // Food items - fruits and vegetables
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 40,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 60,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: 30,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: 50,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 170,
                    left: 25,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 170,
                    left: 45,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Drawers
                  Positioned(
                    bottom: 20,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF9E9E9E)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 55,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF9E9E9E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator({required bool isActive}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4CAF50)
            : const Color(0xFF4CAF50).withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
