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
              // ---------- Stats Row ----------
              Row(
                children: [
                  // Total Machines
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.precision_manufacturing_rounded,
                              color: Color(0xFF2979FF), size: 26),
                          const SizedBox(height: 6),
                          Text(
                            '${_machines.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2979FF),
                            ),
                          ),
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Working
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF00C853), size: 26),
                          const SizedBox(height: 6),
                          Text(
                            '${_machines.where((m) => m.isWorking).length}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00C853),
                            ),
                          ),
                          Text(
                            'Working',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Fault
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_rounded,
                              color: Color(0xFFFF1744), size: 26),
                          const SizedBox(height: 6),
                          Text(
                            '${_machines.where((m) => m.isFault).length}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF1744),
                            ),
                          ),
                          Text(
                            'Fault',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    if (machine.isFault) {
      return const Color(0xFF1E1E1E); // Dark charcoal for fault machines
    }
    return const Color(0xFF2979FF); // Bright blue for working machines
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
                      machineId:
                          mc, // Using mc as both id and name for legacy function
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
