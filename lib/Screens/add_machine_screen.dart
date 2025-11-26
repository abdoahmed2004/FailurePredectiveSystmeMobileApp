import 'package:flutter/material.dart';
import 'package:fpms_app/core/constants/app_colors.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({super.key});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _typeController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the theme setting passed from Home Page
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isDarkMode = args?['isDarkMode'] ?? true; // Default to dark

    // 2. Define Dynamic Colors
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.white.withOpacity(0.9);
    final inputFillColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
    final borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final hintColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image with Theme-aware Effect
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_2.png',
              fit: BoxFit.cover,
              // Darken image in dark mode, lighten in light mode
              color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.2),
              colorBlendMode: isDarkMode ? BlendMode.darken : BlendMode.dstATop,
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "Add Machine",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance back button
                    ],
                  ),
                ),

                const Spacer(),

                // 3. The Form Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Enter machine data:",
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildLabel("Machine Type", textColor),
                        _buildTextField("Ex: CNC Lathe", _typeController, inputFillColor, borderColor, hintColor, textColor),
                        const SizedBox(height: 16),

                        _buildLabel("Machine Name / Model", textColor),
                        _buildTextField("Ex: XJ-2000", _nameController, inputFillColor, borderColor, hintColor, textColor),
                        const SizedBox(height: 16),

                        _buildLabel("Machine ID", textColor),
                        _buildTextField("Ex: #88421", _idController, inputFillColor, borderColor, hintColor, textColor),

                        const SizedBox(height: 32),

                        // Next Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              final type = _typeController.text;
                              final name = _nameController.text;
                              final id = _idController.text;
                              print("Adding Machine: $type, $name, $id");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller,
      Color fillColor,
      Color borderColor,
      Color hintColor,
      Color textColor
      ) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}