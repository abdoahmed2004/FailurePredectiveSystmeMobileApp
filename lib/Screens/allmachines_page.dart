import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fpms_app/Screens/machine_details_page.dart';
import '../Services/auth_service.dart';
import '../Models/machine_model.dart';

class AllMachinesPage extends StatefulWidget {
  const AllMachinesPage({super.key});

  @override
  State<AllMachinesPage> createState() => _AllMachinesPageState();
}

class _AllMachinesPageState extends State<AllMachinesPage> {
  final AuthService _authService = AuthService();
  List<Machine> _machines = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final machines = await _authService.getAllMachines();
      
      if (mounted) {
        setState(() {
          _machines = machines;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ---------- Header ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                      ),
                      Text(
                        "All Machines",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      await Navigator.pushNamed(context, '/add-machine');
                      // Refresh machines list when returning from add machine screen
                      _loadMachines();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---------- Factory Row ----------
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                            radius: 6, backgroundColor: Colors.blue),
                        const SizedBox(width: 8),
                        Text("Factory 1",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                )),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      "${_machines.length} Machines",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (_machines.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 4, backgroundColor: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            "${_machines.where((m) => m.isWorking).length} Working",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 4, backgroundColor: Colors.red),
                          const SizedBox(width: 6),
                          Text(
                            "${_machines.where((m) => m.isFault).length} Fault",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Machines list (scrollable)
              Expanded(
                child: _buildMachinesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachinesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load machines',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMachines,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.precision_manufacturing_outlined, 
                 size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No machines found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first machine to get started',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/add-machine');
                _loadMachines();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Machine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMachines,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _machines.length,
        itemBuilder: (context, index) {
          final machine = _machines[index];
          return machineCardFromApi(
            context: context,
            machine: machine,
            color: _getCardColor(index, machine),
          );
        },
      ),
    );
  }

  Color _getCardColor(int index, Machine machine) {
    // Use darker/muted colors for fault machines
    if (machine.isFault) {
      final faultColors = [
        const Color(0xFF2E2E2E), // Dark gray
        const Color(0xFF4A1A1A), // Dark red
        const Color(0xFF3A1A1A), // Dark brown
        const Color(0xFF2A2A2A), // Darker gray
        const Color(0xFF4A2E2E), // Dark maroon
      ];
      return faultColors[index % faultColors.length];
    }
    
    // Use brighter colors for working machines
    final workingColors = [
      const Color(0xFF0057FF), // Blue
      const Color(0xFF7A00FF), // Purple
      const Color(0xFF0080FF), // Light blue
      const Color(0xFFFF6400), // Orange
      const Color(0xFF00A86B), // Green
    ];
    return workingColors[index % workingColors.length];
  }

  Widget machineCardFromApi({
    required BuildContext context,
    required Machine machine,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + Dot - Using real status data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                machine.statusText,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: machine.statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black.withOpacity(0.3),
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: machine.statusDotColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Machine ID
          Text(
            machine.machineId,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          // Machine Type with status indication
          Text(
            machine.machineType,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: machine.isWorking ? Colors.white : Colors.white70,
            ),
          ),

          const SizedBox(height: 8),

          // Machine Model
          Text(
            machine.machineModel,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 12),

          // Arrow Button
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MachineDetailsPage(
                      machineId: machine.id ?? machine.machineId,
                      machineName: machine.machineId,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget machineCard({
    required BuildContext context,
    required Color color,
    required String status,
    required String mc,
    required String detail,
    required Color detailColor,
    required String operator,
    required String email,
    required Color statusDot,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + Dot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black.withOpacity(0.3),
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: statusDot,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // MC Number
          Text(
            mc,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          // Fault / Working
          Text(
            detail,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: detailColor,
            ),
          ),

          const SizedBox(height: 8),

          // Operator name + email
          Text(
            "$operator  •  $email",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 12),

          // Arrow Button
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MachineDetailsPage(
                      machineId: mc, // Using mc as both id and name for legacy function
                      machineName: mc,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
  }

