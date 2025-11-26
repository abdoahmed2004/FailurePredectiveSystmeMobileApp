import 'package:flutter/material.dart';
import 'package:fpms_app/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fpms_app/Screens/add_machine_screen.dart';
// Screen Imports
import 'package:fpms_app/Screens/splash_screen.dart';
import 'package:fpms_app/Screens/onboarding_screen.dart';
import 'package:fpms_app/Screens/Login_screen.dart';
import 'package:fpms_app/Screens/Register_screen.dart';
import 'package:fpms_app/Screens/home_page.dart';
import 'package:fpms_app/Screens/allmachines_page.dart';
import 'package:fpms_app/Screens/add_machine_screen.dart';
import 'package:fpms_app/Screens/Forget_password_screen.dart';
import 'package:fpms_app/Screens/check_email_screen.dart';
import 'package:fpms_app/Screens/reset_password_screen.dart';
import 'package:fpms_app/Screens/password_changed_success_screen.dart';

// Profile Imports
import 'package:fpms_app/Screens/Profile/profile_screen.dart';
import 'package:fpms_app/Screens/Profile/edit_profile_screen.dart';
import 'package:fpms_app/Screens/Profile/change_password_screen.dart';

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
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),

      initialRoute: '/login',

      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),

        // Machine Routes
        '/machines': (context) => const AllMachinesPage(),
        '/add-machine': (context) => const AddMachineScreen(),

        // Auth Flow Routes
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/check-email': (context) => CheckEmailScreen(
            email: ModalRoute.of(context)!.settings.arguments as String),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/password-changed-success': (context) => const PasswordChangedSuccessScreen(),

        // --- PROFILE ROUTES ---
        '/profile': (context) {
          // Safely extract arguments if they exist
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          return ProfileScreen(
            name: args?['name'] ?? 'User Name',
            email: args?['email'] ?? 'user@example.com',
            role: args?['role'] ?? 'User',
            // === FIX IS HERE ===
            // We provide default values because this standalone route
            // isn't connected to the Home Page's state.
            isDarkMode: true,
            onThemeChanged: (value) {},
          );
        },
        '/edit-profile': (context) => const EditProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}