import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFailureScreen extends StatefulWidget {
  const AddFailureScreen({super.key});

  @override
  State<AddFailureScreen> createState() => _AddFailureScreenState();
}

class _AddFailureScreenState extends State<AddFailureScreen> {
  // Form controllers
  final TextEditingController _machineNameController = TextEditingController();
  final TextEditingController _machineTypeController = TextEditingController();
  final TextEditingController _machineIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form values
  String? _selectedAssignee;
  double _severityLevel = 1.0; // 0=Low, 1=Normal, 2=Critical
  bool _isLoading = false;

  // Sample assignees - replace with backend data
  final List<String> _assignees = [
    'Ali Ahmed',
    'Sara Mohamed',
    'Ahmed Hassan',
    'Fatima Ali',
    'Omar Khaled',
  ];

  @override
  void dispose() {
    _machineNameController.dispose();
    _machineTypeController.dispose();
    _machineIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Get theme values from arguments
  bool get isDarkMode {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['isDarkMode'] ?? true;
  }

  String _getSeverityText() {
    if (_severityLevel <= 0.5) return 'Low';
    if (_severityLevel <= 1.5) return 'Normal';
    return 'Critical';
  }

  Color _getSeverityColor() {
    if (_severityLevel <= 0.5) return Colors.green;
    if (_severityLevel <= 1.5) return Colors.orange;
    return Colors.red;
  }

  void _handleSubmit() async {
    // Validation
    if (_machineNameController.text.isEmpty ||
        _machineTypeController.text.isEmpty ||
        _machineIdController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedAssignee == null) {
      _showSnackbar('Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API call
      // Example:
      // await FailureService().reportFailure(
      //   machineName: _machineNameController.text,
      //   machineType: _machineTypeController.text,
      //   machineId: _machineIdController.text,
      //   description: _descriptionController.text,
      //   assignedTo: _selectedAssignee!,
      //   severity: _getSeverityText().toLowerCase(),
      // );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _showSnackbar('Failure reported successfully!', isError: false);

      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackbar('Failed to report failure: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final textColorLight = isDarkMode ? Colors.white70 : Colors.black54;
    final bgColor =
        isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5);
    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode ? Colors.white24 : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report Failure',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                'Log a new incident for a machine',
                style: GoogleFonts.poppins(
                  color: textColorLight,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              // Machine Name & Machine Type
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _machineNameController,
                      label: 'Machine Name',
                      textColor: textColor,
                      textColorLight: textColorLight,
                      cardBg: cardBg,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _machineTypeController,
                      label: 'Machine Type',
                      textColor: textColor,
                      textColorLight: textColorLight,
                      cardBg: cardBg,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Machine ID & Description
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _machineIdController,
                      label: 'Machine ID',
                      textColor: textColor,
                      textColorLight: textColorLight,
                      cardBg: cardBg,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 1,
                      textColor: textColor,
                      textColorLight: textColorLight,
                      cardBg: cardBg,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Assign To Dropdown
              _buildDropdown(
                value: _selectedAssignee,
                label: 'Assign To',
                items: _assignees,
                onChanged: (value) => setState(() => _selectedAssignee = value),
                textColor: textColor,
                textColorLight: textColorLight,
                cardBg: cardBg,
                borderColor: borderColor,
              ),

              const SizedBox(height: 32),

              // Severity Level
              Text(
                'Severity level',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Severity Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _getSeverityColor(),
                      inactiveTrackColor:
                          isDarkMode ? Colors.white24 : Colors.grey[300],
                      thumbColor: _getSeverityColor(),
                      overlayColor: _getSeverityColor().withOpacity(0.2),
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: _severityLevel,
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (value) =>
                          setState(() => _severityLevel = value),
                    ),
                  ),

                  // Severity Labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Low',
                          style: GoogleFonts.poppins(
                            color: _severityLevel <= 0.5
                                ? Colors.green
                                : textColorLight,
                            fontSize: 12,
                            fontWeight: _severityLevel <= 0.5
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Normal',
                          style: GoogleFonts.poppins(
                            color: _severityLevel > 0.5 && _severityLevel <= 1.5
                                ? Colors.orange
                                : textColorLight,
                            fontSize: 12,
                            fontWeight:
                                _severityLevel > 0.5 && _severityLevel <= 1.5
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Critical',
                          style: GoogleFonts.poppins(
                            color: _severityLevel > 1.5
                                ? Colors.red
                                : textColorLight,
                            fontSize: 12,
                            fontWeight: _severityLevel > 1.5
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Log Failure',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required Color textColorLight,
    required Color cardBg,
    required Color borderColor,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textColorLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    required Color textColor,
    required Color textColorLight,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textColorLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Select assignee',
                style: GoogleFonts.poppins(color: textColorLight, fontSize: 14),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: textColor),
              dropdownColor: cardBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              borderRadius: BorderRadius.circular(8),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
