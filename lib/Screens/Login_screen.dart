import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// --- ADDED IMPORTS ---
import '../Services/auth_service.dart';
import '../Models/user_model.dart';
import 'Register_screen.dart';
// ---------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- ADDED CONTROLLERS AND STATE ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  // -----------------------------------

  bool rememberMe = false;
  bool obscurePassword = true;

  // Helper to show messages to the user
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- LOGIN FUNCTION INTEGRATION ---
  void _handleLogin() async {
    // --- Local Validation ---
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackbar("Please enter both email and password.", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --- API Call to Node.js Backend ---
      final AuthResponse response = await AuthService().loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // --- Success Handling ---
      _showSnackbar(
          "Login successful! Welcome, ${response.user.fullName} (${response.user.role})!",
          isError: false);

      // Navigate to Home and clear back stack, passing user role
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: {
          'userRole': response.user.role,
          'userName': response.user.fullName,
        },
      );

      // Optionally log token for debugging
      print("Token received: ${response.token}");
    } catch (e) {
      // --- Error Handling (e.g., Invalid Credentials) ---
      _showSnackbar(
          "Login Failed: ${e.toString().replaceAll('Exception: ', '')}",
          isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // -------------------------------------

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
                // Register button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to the RegistrationScreen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Register",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Welcome text
                Text(
                  "Welcome back!",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Please login to your account",
                  style:
                      GoogleFonts.poppins(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextField(
                  controller: _emailController, // ADDED
                  keyboardType: TextInputType.emailAddress, // ADDED
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.white54),
                    hintText: 'Email',
                    hintStyle: GoogleFonts.poppins(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF9800)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF9800), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController, // ADDED
                  obscureText: obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.white54),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    hintText: 'Password',
                    hintStyle: GoogleFonts.poppins(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      // Ensure all borders match the style
                      borderSide: const BorderSide(color: Color(0xFFFF9800)),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Remember me + Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFFFF9800),
                        ),
                        Text(
                          "Remember me",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/forgot-password'); // Use actual route
                        //_showSnackbar("Forgot password functionality not implemented.", isError: false);
                      },
                      child: Text(
                        "Forgot password?",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF9800),
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 25),

                // Continue button
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
                    onPressed: _isLoading
                        ? null
                        : _handleLogin, // INTEGRATED LOGIN CALL
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black) // ADDED LOADING STATE
                        : Text(
                            "Continue",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    "or login with",
                    style: GoogleFonts.poppins(color: Colors.white54),
                  ),
                ),

                const SizedBox(height: 20),

                // Google and Apple buttons
                Column(
                  children: [
                    _buildSocialButton(Icons.g_mobiledata, "Google"),
                    const SizedBox(height: 12),
                    _buildSocialButton(Icons.apple, "Apple"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for social buttons
  Widget _buildSocialButton(IconData icon, String text) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1A),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
