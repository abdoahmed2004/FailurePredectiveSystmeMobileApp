import 'package:flutter/material.dart';
import 'package:fpms_app/core/constants/app_colors.dart';

// Import all your screens
import 'package:fpms_app/Screens/splash_screen.dart';
import 'package:fpms_app/Screens/onboarding_screen.dart'; // <-- IMPORT NEW SCREEN
import 'package:fpms_app/Screens/Login_screen.dart';
import 'package:fpms_app/Screens/Register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Machinify',

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.appBlack,
        primaryColor: AppColors.appWhite,
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(), // <-- ADD THIS ROUTE
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}