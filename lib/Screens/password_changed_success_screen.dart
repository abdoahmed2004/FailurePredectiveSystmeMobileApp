import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordChangedSuccessScreen extends StatelessWidget {
  const PasswordChangedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎉 Success Circle Icon
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF9800), width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFFF9800),
                  size: 60,
                ),
              ),

              const SizedBox(height: 40),

              // 🎯 Title
              Text(
                "Password Changed!",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // 📝 Message
              Text(
                "Your password has been successfully changed.\nYou can now log in with your new password.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              // 🔙 Back to Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "Back to Login",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
