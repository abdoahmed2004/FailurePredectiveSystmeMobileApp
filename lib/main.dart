import 'package:flutter/material.dart';
import 'package:fpms_app/Screens/Forget_password_screen.dart';
import 'package:fpms_app/Screens/check_email_screen.dart';
import 'package:fpms_app/Screens/home_page.dart';
import 'package:fpms_app/Screens/password_changed_success_screen.dart';
import 'package:fpms_app/Screens/profile_screen.dart';
import 'package:fpms_app/Screens/reset_password_screen.dart';
import 'package:fpms_app/core/constants/app_colors.dart';

// Import all your screens
import 'package:fpms_app/Screens/splash_screen.dart';
import 'package:fpms_app/Screens/onboarding_screen.dart'; // <-- IMPORT NEW SCREEN
import 'package:fpms_app/Screens/Login_screen.dart';
import 'package:fpms_app/Screens/Register_screen.dart';
import 'package:fpms_app/Screens/allmachines_page.dart';
import 'package:fpms_app/Screens/add_machine_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

      initialRoute: '/home', // <-- SET INITIAL ROUTE HERE

      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/machines': (context) => const AllMachinesPage(),
        '/add-machine': (context) => const AddMachineScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/check-email': (context) => CheckEmailScreen(
            email: ModalRoute.of(context)!.settings.arguments as String),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/password-changed-success': (context) =>
            const PasswordChangedSuccessScreen(),
        '/profile': (context) => ProfileScreen(
              name: ModalRoute.of(context)!.settings.arguments != null
                  ? (ModalRoute.of(context)!.settings.arguments
                      as Map<String, String>)['name']!
                  : 'User Name',
              email: ModalRoute.of(context)!.settings.arguments != null
                  ? (ModalRoute.of(context)!.settings.arguments
                      as Map<String, String>)['email']!
                  : 'user@example.com',
              role: ModalRoute.of(context)!.settings.arguments != null
                  ? (ModalRoute.of(context)!.settings.arguments
                      as Map<String, String>)['role']!
                  : 'User',
            ),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
