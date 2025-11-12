import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import your new AppColors file
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  // === Asset Path (REPLACE THIS) ===
  // We only need the logo now
  final String _logo = 'assets/images/logo.png';

  late Animation<Offset> _logoDropAnimation;
  late Animation<double> _logoFlipAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;

  bool _showSecondBackground = false;
  bool _animationComplete = false;

  final Duration _totalDuration = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _totalDuration);

    // [0.0 - 0.25] Logo Drops
    _logoDropAnimation = Tween<Offset>(
      begin: const Offset(0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.elasticOut),
    ));

    // [0.3 - 0.75] Flip Sequence
    _logoFlipAnimation = TweenSequence<double>([
      // Flip 1: 0 to 180 degrees (pi)
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: pi),
        weight: 1.0, // Interval(0.3, 0.5)
      ),
      // Pause
      TweenSequenceItem(
        tween: ConstantTween(pi),
        weight: 0.2, // Interval(0.5, 0.55)
      ),
      // Flip 2: 180 back to 0 degrees (inverted)
      TweenSequenceItem(
        tween: Tween(begin: pi, end: 0.0), // <-- *** THE CHANGE IS HERE ***
        weight: 1.0, // Interval(0.55, 0.75)
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.75),
    ));

    // [0.75 - 0.9] Logo Zooms Out
    _logoScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 0.9, curve: Curves.easeOut),
    ));

    // [0.8 - 1.0] Text Fades In
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    ));

    _controller.addListener(() {
      // At 50% (halfway through the flip), change the background
      if (_controller.value >= 0.5 && !_showSecondBackground) {
        setState(() {
          _showSecondBackground = true;
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationComplete = true;
        });
        HapticFeedback.lightImpact();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    // Only navigate if the animation is done
    if (_animationComplete) {
      // === THIS IS THE CHANGE ===
      // Navigate to Onboarding instead of Login
      Navigator.pushReplacementNamed(context, '/onboarding');
      // === END OF CHANGE ===
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToLogin,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // --- Background 1 (NOW A GRADIENT) ---
            // Fades out as Background 2 fades in
            AnimatedOpacity(
              opacity: _showSecondBackground ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              // This is the main change
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.splashGradientStart,
                      AppColors.splashGradientEnd,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // --- Background 2 (Final Black) ---
            AnimatedOpacity(
              opacity: _showSecondBackground ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(color: AppColors.appBlack),
            ),

            // --- Center Content (Logo & Text) ---
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: _logoDropAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateY(_logoFlipAnimation.value),
                            alignment: Alignment.center,
                            child: Image.asset(
                              _logo,
                              width: 150,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 100),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: const [
                            Text(
                              "Machinify",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.appWhite,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "A totally new approach to factory\nmaintenance and management",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}