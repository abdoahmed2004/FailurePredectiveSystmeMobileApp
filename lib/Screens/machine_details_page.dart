import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/auth_service.dart';
import '../Models/machine_model.dart';

class MachineDetailsPage extends StatefulWidget {
  final String machineId;
  final String machineName;

  const MachineDetailsPage({
    super.key, 
    required this.machineId,
    required this.machineName,
  });

  @override
  State<MachineDetailsPage> createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {
  final AuthService _authService = AuthService();
  Machine? _machine;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMachineDetails();
  }

  Future<void> _loadMachineDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final machine = await _authService.getMachineById(widget.machineId);
      
      if (mounted) {
        setState(() {
          _machine = machine;
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
      //backgroundColor: Colors.white,
      appBar: AppBar(
        //backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _machine?.machineId ?? widget.machineName,
          style: GoogleFonts.poppins(
           
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading machine details',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMachineDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Machine Info Card
                      if (_machine != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _machine!.isWorking ? Icons.check_circle : Icons.error,
                                    color: _machine!.statusColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _machine!.statusText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: _machine!.statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('Machine ID', _machine!.machineId),
                              _buildInfoRow('Model', _machine!.machineModel),
                              _buildInfoRow('Type', _machine!.machineType),
                            ],
                          ),
                        ),
                      ],
                      
                      // Sensor Data Section
                      if (_machine?.temperature != null)
                        sensorTile(
                          icon: Icons.thermostat,
                          label: "Temperature",
                          time: "Real-time",
                          value: "${_machine!.temperature!.toStringAsFixed(1)}°C",
                        ),
                      if (_machine?.pressure != null)
                        sensorTile(
                          icon: Icons.speed,
                          label: "Pressure",
                          time: "Real-time",
                          value: "${_machine!.pressure!.toStringAsFixed(1)} bar",
                        ),
                      if (_machine?.humidity != null)
                        sensorTile(
                          icon: Icons.water_drop,
                          label: "Humidity",
                          time: "Real-time",
                          value: "${_machine!.humidity!.toStringAsFixed(1)}%",
                        ),
                      if (_machine?.vibration != null)
                        sensorTile(
                          icon: Icons.blur_circular,
                          label: "Vibration",
                          time: "Real-time",
                          value: "${_machine!.vibration!.toStringAsFixed(1)} Hz",
                        ),
                      if (_machine?.toolWear != null)
                        sensorTile(
                          icon: Icons.construction,
                          label: "Tool wear",
                          time: "Real-time",
                          value: "${_machine!.toolWear!.toStringAsFixed(0)}%",
                        ),
                      if (_machine?.rotationalSpeed != null)
                        sensorTile(
                          icon: Icons.rotate_right,
                          label: "Rotational Speed",
                          time: "Real-time",
                          value: "${_machine!.rotationalSpeed!.toStringAsFixed(0)} RPM",
                        ),
                      if (_machine?.torque != null)
                        sensorTile(
                          icon: Icons.auto_fix_high,
                          label: "Torque",
                          time: "Real-time",
                          value: "${_machine!.torque!.toStringAsFixed(1)} Nm",
                        ),
                      if (_machine?.airTemperature != null)
                        sensorTile(
                          icon: Icons.air,
                          label: "Air Temperature",
                          time: "Real-time",
                          value: "${_machine!.airTemperature!.toStringAsFixed(1)}°C",
                        ),
                      if (_machine?.processTemperature != null)
                        sensorTile(
                          icon: Icons.local_fire_department,
                          label: "Process Temperature",
                          time: "Real-time",
                          value: "${_machine!.processTemperature!.toStringAsFixed(1)}°C",
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Sensor Row Widget
  Widget sensorTile({
    required IconData icon,
    required String label,
    required String time,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // icon + label + time
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5CC),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(icon, size: 26, color: const Color(0xFFDC6A1F)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                     
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Number only (black)
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            // as requested
            ),
          ),
        ],
      ),
    );
  }
}
