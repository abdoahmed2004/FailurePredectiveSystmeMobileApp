import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 🧑‍💼 Profile Icon
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: const Color(0xFFFF9800),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFFF9800),
                size: 80,
              ),
            ),

            const SizedBox(height: 25),

            // 📝 User Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9800), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel("ID"),
                  _buildUserData("123456789"),
                  const SizedBox(height: 16),
                  
                  _buildFieldLabel("Full Name"),
                  _buildUserData(name),
                  const SizedBox(height: 16),

                  _buildFieldLabel("Email"),
                  _buildUserData(email),
                  const SizedBox(height: 16),

                  _buildFieldLabel("Role"),
                  _buildUserData(role),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ✏️ Edit Profile Button (Optional)
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
                  // Add edit functionality here later
                },
                child: Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9800),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟠 Label widget
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white54,
        fontSize: 14,
      ),
    );
  }

  // 🟠 Data widget
  Widget _buildUserData(String data) {
    return Text(
      data,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
