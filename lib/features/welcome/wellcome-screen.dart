import 'package:flutter/material.dart';

import '../dashboard/dashboard-screen.dart';

class OnboardingSlide {
  final String title;
  final String subtitle;

  const OnboardingSlide({required this.title, required this.subtitle});
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
      // On last slide, proceed to main app
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome! Let\'s get started!'),
          duration: Duration(seconds: 2),
        ),
      );
      // TODO: Navigate to main app screen
    }
  }

  void _onSignInPressed(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Refrigerator Illustration
              _buildRefrigeratorIllustration(),
              const SizedBox(height: 40),

              // Title & Subtitle Slider
              Expanded(
                flex: 2,
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
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(flex: 1),

              // Pagination Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildPaginationDot(isActive: index == _currentPage),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _onGetStartedPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _slides.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Sign In (only show on last slide)
              if (_currentPage == _slides.length - 1) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _onSignInPressed(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // Refrigerator Illustration
  // -------------------------------
  Widget _buildRefrigeratorIllustration() {
    return SizedBox(
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
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Refrigerator body
          Positioned(
            bottom: 20,
            child: Container(
              width: 200,
              height: 260,
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
                  Positioned(top: 40, left: 8, right: 8, child: _buildShelf()),
                  Positioned(top: 100, left: 8, right: 8, child: _buildShelf()),
                  Positioned(top: 160, left: 8, right: 8, child: _buildShelf()),

                  // Food items
                  Positioned(
                    top: 50,
                    left: 20,
                    child: _buildFoodItem(Colors.orange, 12),
                  ),
                  Positioned(
                    top: 50,
                    left: 40,
                    child: _buildFoodItem(Colors.red, 10),
                  ),
                  Positioned(
                    top: 110,
                    left: 30,
                    child: _buildFoodItem(Colors.green, 14),
                  ),
                  Positioned(
                    top: 170,
                    left: 25,
                    child: _buildFoodItem(Colors.yellow, 11),
                  ),

                  // Drawers
                  Positioned(
                    bottom: 20,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0).withOpacity(0.6),
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
                        color: const Color(0xFFE0E0E0).withOpacity(0.6),
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

  Widget _buildShelf() {
    return Container(height: 2, color: const Color(0xFF9E9E9E));
  }

  Widget _buildFoodItem(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // -------------------------------
  // Animated Pagination Dots
  // -------------------------------
  Widget _buildPaginationDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4CAF50)
            : const Color(0xFF4CAF50).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
