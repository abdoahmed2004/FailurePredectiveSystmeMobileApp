import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/auth_service.dart';
import 'login_screen.dart'; 
import 'check_email_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;
  
  String? selectedRole;
  final List<String> roles = ['Manager', 'Admin', 'Engineer', 'Technician']; 

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (selectedRole == null) {
      _showSnackbar("Please select a role.", isError: true);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackbar("Passwords do not match.", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final roleApi = selectedRole!.toLowerCase(); 

      await AuthService().registerUser(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: roleApi,
      );

      _showSnackbar("Registration successful! Email sent.", isError: false);
      
      // Navigate to the Check Email Screen after success
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CheckEmailScreen(email: _emailController.text.trim()), 
        ),
      );

    } catch (e) {
      _showSnackbar("Registration Failed: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back icon and Login button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white70, size: 20),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFF9800),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Please fill the details to register",
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // Name Field
                  _buildInputField(
                    controller: _fullNameController, 
                    label: "Full Name",
                    icon: Icons.person_outline,
                    hint: "Enter your name",
                    validator: (value) => value!.isEmpty ? 'Full name is required.' : null,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  _buildInputField(
                    controller: _emailController, 
                    label: "Email",
                    icon: Icons.email_outlined,
                    hint: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildPasswordField(
                    controller: _passwordController, 
                    label: "Password",
                    hint: "Enter password",
                    obscureText: obscurePassword,
                    onToggle: () => setState(() {
                      obscurePassword = !obscurePassword;
                    }),
                    validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters.' : null,
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _buildPasswordField(
                    controller: _confirmPasswordController, 
                    label: "Confirm Password",
                    hint: "Re-enter password",
                    obscureText: obscureConfirmPassword,
                    onToggle: () => setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    }),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Role Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF9800)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF121212),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        value: selectedRole,
                        isExpanded: true,
                        hint: Text(
                          "Select Role",
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(
                              role,
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Register Button
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
                      onPressed: _isLoading ? null : _handleRegistration, 
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black) 
                          : Text(
                              "Register",
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
                      "or register with",
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
      ),
    );
  }

  // 🔸 Reusable Input Field 
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF121212),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  // 🔸 Reusable Password Field 
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white54,
          ),
          onPressed: onToggle,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF121212),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  // 🔸 Reusable Social Login Button
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