import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // 📧 Email Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF9800), width: 2),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFFF9800),
                  size: 60,
                ),
              ),

              const SizedBox(height: 40),

              // 🧾 Title
              Text(
                "Check Your Email",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // 💬 Description
              Text(
                "We’ve sent a password reset link to your email.\nPlease check your inbox and follow the instructions.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              // 🔁 Resend Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFFF9800),
                        content: Text(
                          "Reset link resent successfully!",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Resend",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9800),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Done Button
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
                    Navigator.pushNamed(context, '/reset-password');
                  },
                  child: Text(
                    "Done",
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
