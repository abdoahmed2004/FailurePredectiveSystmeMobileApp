import 'dart:io'; // Needed to read file paths
import 'package:flutter/material.dart';
import 'package:fpms_app/core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart'; // Import the package

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _dateController = TextEditingController();
  bool _isInit = true;

  // === NEW: Variable to hold the selected image ===
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _dateController.text = "1999/09/21";
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // === NEW: Function to show dialog to choose Camera or Gallery ===
  void _showImageSourceDialog(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.primaryOrange),
                title: Text('Gallery', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt,
                    color: AppColors.primaryOrange),
                title: Text('Camera', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // === NEW: Function to pick image using the package ===
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image slightly
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
      }
    } catch (e) {
      // Handle any errors here (e.g., permission denied)
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to pick image. Check permissions.')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDarkMode) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999, 9, 21),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: isDarkMode
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primaryOrange,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                    surface: Color(0xFF1E1E1E),
                  ),
                  dialogTheme:
                      DialogThemeData(backgroundColor: const Color(0xFF1E1E1E)),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryOrange,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final initialName = args?['name'] ?? "Jessica Jung";
    final initialEmail = args?['email'] ?? "jessica@example.com";
    final isDarkMode = args?['isDarkMode'] ?? true;

    final backgroundColor = isDarkMode ? const Color(0xFF0F0F0F) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final inputTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.splashGradientStart,
                  AppColors.splashGradientEnd
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. AppBar Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Edit Your Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 3. Main Content Card
          Container(
            margin: const EdgeInsets.only(top: 180),
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                      label: "Full Name",
                      textColor: textColor,
                      inputColor: inputTextColor,
                      initialValue: initialName),
                  const SizedBox(height: 20),
                  _buildTextField(
                      label: "Email",
                      textColor: textColor,
                      inputColor: inputTextColor,
                      initialValue: initialEmail),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Date Of Birth",
                    textColor: textColor,
                    inputColor: inputTextColor,
                    controller: _dateController,
                    icon: Icons.calendar_today_outlined,
                    isReadOnly: true,
                    onTap: () => _selectDate(context, isDarkMode),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Here you would save the new image (_pickedImage) and data to Firebase
                        print("Saving profile...");
                        if (_pickedImage != null) {
                          print("New image path: ${_pickedImage!.path}");
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating Avatar
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    // === UPDATED AVATAR LOGIC ===
                    // If an image is picked, show it. Otherwise show placeholder.
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path)) as ImageProvider
                          : const AssetImage('assets/images/onboarding_1.png'),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    // === WRAPPED WITH GESTURE DETECTOR ===
                    child: GestureDetector(
                      onTap: () => _showImageSourceDialog(isDarkMode),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Color textColor,
    required Color inputColor,
    String? initialValue,
    TextEditingController? controller,
    IconData? icon,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          style: TextStyle(color: inputColor),
          decoration: InputDecoration(
            suffixIcon: icon != null
                ? Icon(icon, color: AppColors.primaryOrange)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.primaryOrange),
            ),
          ),
        ),
      ],
    );
  }
}
