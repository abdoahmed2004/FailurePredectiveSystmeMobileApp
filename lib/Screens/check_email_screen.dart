import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Login_screen.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;
  final bool isPasswordReset; // <-- NEW FLAG for context

  const CheckEmailScreen({
    super.key,
    required this.email,
    this.isPasswordReset = false, // Defaults to false (Registration)
  });

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  bool _isResending = false;

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFFF9800),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // NOTE: This logic is currently set for email VERIFICATION RESEND,
  // not password reset resend, as the password reset link is time-sensitive
  // and the entire process must be restarted. We keep the button for UX flow.
  void _handleResend() async {
    // Only allow resending if it's the REGISTRATION flow
    if (widget.isPasswordReset) {
      _showSnackbar(
          "Please use the 'Forgot Password' button on the Login screen to restart the reset process.",
          isError: true);
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      // NOTE: This call assumes a 'resendVerificationEmail' route exists on the backend.
      // Since we don't have that, we mock success for the verification path.
      await Future.delayed(const Duration(seconds: 1));

      _showSnackbar("New verification email sent successfully!",
          isError: false);
    } catch (e) {
      _showSnackbar("Resend Failed: Server Error", isError: true);
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the descriptive text based on the flag
    final String titleText =
        widget.isPasswordReset ? "Reset Link Sent" : "Check Your Email";
    final String descriptionText = widget.isPasswordReset
        ? "We’ve sent a password reset link to ${widget.email}. Please click the link to set your new password in your browser."
        : "We’ve sent a verification link to ${widget.email}.\nPlease check your inbox and follow the instructions.";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),

              // 📧 Email Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFFF9800), width: 2),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFFFF9800),
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 🧾 Title (Dynamic)
              Text(
                titleText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // 💬 Description (Dynamic)
              Text(
                descriptionText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              // 🔁 Resend Button (Only active for registration flow)
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Disable if it's the password reset flow
                  onPressed: widget.isPasswordReset
                      ? null
                      : (_isResending ? null : _handleResend),
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Color(0xFFFF9800), strokeWidth: 2),
                        )
                      : Text(
                          "Resend",
                          style: GoogleFonts.poppins(
                            color: widget.isPasswordReset
                                ? Colors.white54
                                : const Color(0xFFFF9800),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Done Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Navigate back to the Login Screen, removing all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
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
