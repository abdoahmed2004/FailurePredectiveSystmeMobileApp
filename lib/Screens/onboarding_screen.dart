import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpms_app/core/constants/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// A model for each onboarding page's data
class OnboardingPageModel {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPageModel({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Define the content for your 3 pages
  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Real-time status and health indicators.',
      description: 'Stay included in every aspect of your machine lifecycle!',
    ),
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Provide automatic alerts',
      description:
      'when maintenance is due or a failure is predicted you\'ll get alerted with the exact date',
    ),
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Predict upcoming faults',
      description: 'based on machine data (temperature, vibration, runtime, etc.)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Update the current page index when the page changes
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark, // Makes status bar icons (time, battery) white
        child: Stack(
          fit: StackFit.expand, // Make the stack fill the screen
          children: [
            // --- 1. Background Image PageView ---
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(context, _pages[index]);
              },
            ),

            // === THIS IS THE WIDGET FOR THE SHADOW ===
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                // Make the gradient shadow cover the bottom 50% of the screen
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // Start with a strong black
                      Colors.black.withOpacity(0.8),
                      // Fade to completely transparent
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // === END OF SHADOW WIDGET ===

            // --- 2. Top UI (Back, Skip, Dots) ---
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Back or Dots ---
                  _currentPage > 0
                      ? _buildNavButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  )
                      : _buildPageIndicator(), // Show dots only on first page

                  // --- Skip Button ---
                  if (!isLastPage)
                    _buildNavButton(
                      text: "Skip",
                      onPressed: _navigateToLogin,
                    ),
                ],
              ),
            ),

            // --- 3. Bottom UI (Text & Next/Start Button) ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Dots (only after first page) ---
                    if (_currentPage > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildPageIndicator(),
                      ),

                    // --- Animated Text ---
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Column(
                        key: ValueKey<int>(_currentPage), // Important!
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pages[_currentPage].title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _pages[_currentPage].description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- Next / Start Button ---
                    _buildActionButton(
                      text: isLastPage ? "Let's start!" : (_currentPage == 0 ? "Get Started" : "Next"),
                      onPressed: () {
                        if (isLastPage) {
                          _navigateToLogin();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPage(BuildContext context, OnboardingPageModel page) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(page.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: _pages.length,
      effect: const WormEffect(
        dotHeight: 10,
        dotWidth: 10,
        activeDotColor: AppColors.primaryOrange,
        dotColor: Colors.white54,
      ),
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), // Make it a pill
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded, size: 24),
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 40), // To balance the icon
        ],
      ),
    );
  }

  Widget _buildNavButton({IconData? icon, String? text, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 16),
            if (icon != null && text != null) const SizedBox(width: 8),
            if (text != null)
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}