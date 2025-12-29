import 'dart:math';

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
      'When maintenance is due or a failure is predicted, you\'ll get alerted with the exact date',
    ),
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Predict upcoming faults',
      description: 'Based on machine data (temperature, vibration, runtime, etc.)',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --- Background PageView ---
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(context, _pages[index]);
              },
            ),

            // --- Shadow at bottom ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // --- Top UI: Back & Skip ---
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      : _buildPageIndicator(), 
                  if (!isLastPage)
                    _buildNavButton(
                      text: "Skip",
                      onPressed: _navigateToLogin,
                    ),
                ],
              ),
            ),

            // --- Bottom UI: Text & Slide Button ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentPage > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildPageIndicator(),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Column(
                        key: ValueKey<int>(_currentPage),
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
                    // --- Slide-to-Enter Button ---
                    SlideToEnterButton(
                      text: isLastPage
                          ? "Let's start!"
                          : (_currentPage == 0 ? "Get Started" : "Next"),
                      isLastPage: isLastPage,
                      onCompleted: () {
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

  Widget _buildNavButton(
      {IconData? icon, String? text, required VoidCallback onPressed}) {
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
                style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

// === Slide-To-Enter Button with Ripple Effect for Last Slide ===
class SlideToEnterButton extends StatefulWidget {
  final String text;
  final bool isLastPage;
  final VoidCallback onCompleted;

  const SlideToEnterButton({
    super.key,
    required this.text,
    required this.isLastPage,
    required this.onCompleted,
  });

  @override
  State<SlideToEnterButton> createState() => _SlideToEnterButtonState();
}

class _SlideToEnterButtonState extends State<SlideToEnterButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isExpanding = false;

  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _rippleController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(const Duration(milliseconds: 200));
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SlideToEnterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _dragPosition = 0.0;
        _isExpanding = false;
        _rippleController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width - 30 * 2 - 60;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate the maximum radius needed to cover the screen
    final double centerX = _dragPosition + 30; // draggable center
    final double centerY = 30.0; // button vertical center
    final double dx = max(centerX, screenWidth - centerX);
    final double dy = max(centerY, screenHeight - centerY);
    final double maxRadius = sqrt(dx * dx + dy * dy) * 2;

    _rippleAnimation = Tween<double>(begin: 60, end: maxRadius).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCubic),
    );

    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none,
        children: [
          // --- Ripple Expansion for last slide ---
          if (_isExpanding && widget.isLastPage)
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return Positioned(
                  left: centerX - _rippleAnimation.value / 2,
                  top: centerY - _rippleAnimation.value / 2,
                  child: Container(
                    width: _rippleAnimation.value,
                    height: _rippleAnimation.value,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),

          // --- Normal button ---
          if (!_isExpanding)
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Orange fill background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: _dragPosition + 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),

                  // Center text
                  Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isExpanding ? 0 : 1,
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Draggable circle
                  Positioned(
                    left: _dragPosition,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _dragPosition += details.delta.dx;
                          _dragPosition = _dragPosition.clamp(0.0, maxWidth);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_dragPosition >= maxWidth) {
                          if (widget.isLastPage) {
                            setState(() {
                              _isExpanding = true;
                            });
                            _rippleController.forward();
                          } else {
                            widget.onCompleted();
                          }
                        } else {
                          setState(() {
                            _dragPosition = 0.0;
                          });
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}