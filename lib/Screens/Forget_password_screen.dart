import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// --- ADDED IMPORTS ---
import '../Services/auth_service.dart';
// Note: We don't need a token screen, but we do need a Confirmation screen
import 'check_Email_Screen.dart'; 
// ---------------------

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  // --- ADDED STATE ---
  bool _isLoading = false;
  // -------------------

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFFF9800), // Amber for success
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // --- API INTEGRATION FUNCTION ---
  void _handleSendLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackbar("Please enter your email address", isError: true);
      return;
    }
    
    // Optional: Simple email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
       _showSnackbar("Please enter a valid email address.", isError: true);
       return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Call the backend API to initiate the password reset process
      await AuthService().forgotPassword(email: email);
      
      // 2. If the API call succeeds (Status 200), navigate to the confirmation screen.
      // The backend returns a generic success message to prevent user enumeration,
      // so we navigate immediately and let the user check their email.
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CheckEmailScreen(email: email), // Use CheckEmailScreen for confirmation
        ),
      );

    } catch (e) {
      // 3. Show error if network fails or the API returns a non-200 status
      _showSnackbar("Failed: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 Back icon
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white70, size: 20),
                ),
                const SizedBox(height: 40),

                // 🧾 Title
                Text(
                  "Forgot Password?",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your email address to receive a password reset link.",
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // 📧 Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress, // Added keyboard type
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Color(0xFFFF9800)),
                    hintText: 'Email',
                    hintStyle: GoogleFonts.poppins(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF9800)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF9800),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🚀 Send Button
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
                    onPressed: _isLoading ? null : _handleSendLink, // Call API integration
                    child: _isLoading 
                      ? const Center(child: SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        ))
                      : Text(
                          "Send Reset Link",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to LoginScreen
                    },
                    child: Text(
                      "Back to Login",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}