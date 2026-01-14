import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/auth_service.dart';
import '../Models/user_model.dart';
import '../Models/machine_model.dart';

class AddFailureScreen extends StatefulWidget {
  const AddFailureScreen({super.key});

  @override
  State<AddFailureScreen> createState() => _AddFailureScreenState();
}

class _AddFailureScreenState extends State<AddFailureScreen> {
  // Form controllers
  final TextEditingController _machineNameController = TextEditingController();
  final TextEditingController _machineTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form values
  String? _selectedAssignee;
  String? _selectedMachineId; // Mongo ObjectId for machine
  double _severityLevel = 1.0; // 0=Low, 1=Normal, 2=Critical
  bool _isLoading = false;
  bool _isLoadingAssignees = false;
  bool _isLoadingMachines = false;

  // Technicians fetched from backend
  List<User> _technicians = [];
  // Machines fetched from backend
  List<Machine> _machines = [];

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
    _loadMachines();
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    _machineTypeController.dispose();
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
    if (_severityLevel <= 1.5) return 'Medium';
    return 'Critical';
  }

  String _mapSeverityForApi() {
    if (_severityLevel <= 0.5) return 'low';
    if (_severityLevel <= 1.5) return 'medium';
    return 'critical';
  }

  String _resolveMachineIdForApi() {
    if (_selectedMachineId != null && _selectedMachineId!.isNotEmpty) {
      return _selectedMachineId!;
    }
    throw Exception('Please select a machine.');
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
        _selectedMachineId == null ||
        _descriptionController.text.isEmpty ||
        _selectedAssignee == null) {
      _showSnackbar('Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final me = await AuthService().getPersonalInfo();
      final resolvedMachineId = _resolveMachineIdForApi();
      final message = await AuthService().createFailureReport(
        machineName: _machineNameController.text.trim(),
        machineType: _machineTypeController.text.trim(),
        machineId: resolvedMachineId,
        description: _descriptionController.text.trim(),
        assignedTo: _selectedAssignee!, // send assignee email
        severity: _mapSeverityForApi(),
        assignedBy: me.email, // send reporter email
      );

      _showSnackbar(message, isError: false);

      await Future.delayed(const Duration(milliseconds: 300));
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

  Future<void> _loadTechnicians() async {
    setState(() => _isLoadingAssignees = true);
    try {
      final users = await AuthService().getTechnicians();
      if (!mounted) return;
      setState(() {
        _technicians = users.where((u) => u.fullName.isNotEmpty && u.fullName != 'N/A').toList();
      });
      // Debug: print loaded technicians
      debugPrint('Loaded technicians count: ${_technicians.length}');
      debugPrint('Technicians: ${_technicians.map((e) => '${e.fullName}(${e.id})').join(', ')}');
    } catch (e) {
      if (mounted) _showSnackbar('Failed to load assignees: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingAssignees = false);
    }
  }

  Future<void> _loadMachines() async {
    setState(() => _isLoadingMachines = true);
    try {
      final machines = await AuthService().getAllMachines();
      if (!mounted) return;
      setState(() {
        _machines = machines;
      });
      debugPrint('Loaded machines count: ${_machines.length}');
    } catch (e) {
      if (mounted) _showSnackbar('Failed to load machines: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingMachines = false);
    }
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

              // Machine selection & Description
              Row(
                children: [
                  Expanded(child: _buildMachineDropdown(
                    value: _selectedMachineId,
                    label: 'Machine',
                    items: _machines
                        .map((m) => DropdownMenuItem<String>(
                              value: m.id ?? '',
                              child: Text(
                                '${m.machineModel} (${m.machineId})',
                                style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedMachineId = val;
                        final machine = _machines.firstWhere((m) => (m.id ?? '') == val, orElse: () => _machines.first);
                        _machineNameController.text = machine.machineModel;
                        _machineTypeController.text = machine.machineType;
                      });
                    },
                    textColor: textColor,
                    textColorLight: textColorLight,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  )),
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
              _buildAssignDropdown(
                value: _selectedAssignee,
                label: 'Assign To',
                items: _technicians
                  .map((u) => DropdownMenuItem<String>(
                      value: u.email,
                      child: Text(u.fullName, style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
                    ))
                  .toList(),
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
                          'Medium',
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

  Widget _buildAssignDropdown({
    required String? value,
    required String label,
    required List<DropdownMenuItem<String>> items,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: _isLoadingAssignees
              ? const SizedBox(
                  height: 40,
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
                : items.isEmpty
                  ? SizedBox(
                      height: 48,
                      child: Center(
                        child: Text(
                          'No assignees available',
                          style: GoogleFonts.poppins(color: textColorLight, fontSize: 14),
                        ),
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        hint: Text(
                          'Select assignee',
                          style: GoogleFonts.poppins(color: textColorLight, fontSize: 14),
                        ),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: textColor),
                        dropdownColor: cardBg,
                        borderRadius: BorderRadius.circular(8),
                        items: items,
                        onChanged: onChanged,
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMachineDropdown({
    required String? value,
    required String label,
    required List<DropdownMenuItem<String>> items,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: _isLoadingMachines
              ? const SizedBox(
                  height: 40,
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : items.isEmpty
                  ? SizedBox(
                      height: 48,
                      child: Center(
                        child: Text(
                          'No machines available',
                          style: GoogleFonts.poppins(color: textColorLight, fontSize: 14),
                        ),
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        hint: Text(
                          'Select machine',
                          style: GoogleFonts.poppins(color: textColorLight, fontSize: 14),
                        ),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: textColor),
                        dropdownColor: cardBg,
                        borderRadius: BorderRadius.circular(8),
                        items: items,
                        onChanged: onChanged,
                      ),
                    ),
        ),
      ],
    );
  }
}
