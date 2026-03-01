import 'package:flutter/material.dart';
import 'package:fpms_app/core/theme/app_theme.dart';
import 'package:fpms_app/core/theme/theme_controller.dart';

import 'package:fpms_app/Screens/add_machine_screen.dart';
import 'package:fpms_app/Screens/add_failure_screen.dart';
// Screen Imports
import 'package:fpms_app/Screens/splash_screen.dart';
import 'package:fpms_app/Screens/onboarding_screen.dart';
import 'package:fpms_app/Screens/Login_screen.dart';
import 'package:fpms_app/Screens/Register_screen.dart';
import 'package:fpms_app/Screens/home_page.dart';
import 'package:fpms_app/Screens/allmachines_page.dart';
import 'package:fpms_app/Screens/Forget_password_screen.dart';
import 'package:fpms_app/Screens/check_email_screen.dart';
import 'package:fpms_app/Screens/reset_password_screen.dart';
import 'package:fpms_app/Screens/password_changed_success_screen.dart';

// Profile Imports
import 'package:fpms_app/Screens/Profile/profile_screen.dart';
import 'package:fpms_app/Screens/Profile/edit_profile_screen.dart';
import 'package:fpms_app/Screens/Profile/change_password_screen.dart';

// Engineer Home
import 'package:fpms_app/Screens/engineer_home_page.dart';

// Employee Home
import 'package:fpms_app/Screens/employee_home_page.dart';

// Manager/Admin Home
import 'package:fpms_app/Screens/manager_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, themeMode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Machinify',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          // 🔍 PREVIEW ROUTES – remove when done testing
          '/engineer-preview': (context) =>
              const EngineerHomePage(userName: 'Ahmed Ashraf'),
          '/employee-preview': (context) =>
              const EmployeeHomePage(userName: 'Ali Ahmed'),
          '/manager-preview': (context) =>
              const ManagerHomePage(userName: 'Omar Khaled'),
          '/home': (context) {
            // Extract user role and name from arguments
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final role =
                (args?['userRole'] ?? 'admin').toString().toLowerCase();
            final name = (args?['userName'] ?? 'Engineer').toString();

            // Route role to the correct home page
            if (role == 'engineer') return EngineerHomePage(userName: name);
            if (role == 'technician') return EmployeeHomePage(userName: name);
            if (role == 'admin' || role == 'manager')
              return ManagerHomePage(userName: name);
            return HomePage(userRole: role);
          },

          // Machine Routes
          '/machines': (context) => const AllMachinesPage(),
          '/add-machine': (context) => const AddMachineScreen(),
          '/add-failure': (context) => const AddFailureScreen(),

          // Auth Flow Routes
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/check-email': (context) => CheckEmailScreen(
              email: ModalRoute.of(context)!.settings.arguments as String),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/password-changed-success': (context) =>
              const PasswordChangedSuccessScreen(),

          // --- PROFILE ROUTES ---
          '/profile': (context) => const ProfileScreen(),

          '/edit-profile': (context) => const EditProfileScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
        },
      ),
    );
  }
}
