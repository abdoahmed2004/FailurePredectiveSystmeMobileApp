import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachineDetailsPage extends StatelessWidget {
  final String machineName;

  const MachineDetailsPage({super.key, required this.machineName});

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
          machineName,
          style: GoogleFonts.poppins(
           
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            sensorTile(
              icon: Icons.thermostat,
              label: "Temperature",
              time: "30 min ago",
              value: "1.756",
            ),
            sensorTile(
              icon: Icons.speed,
              label: "Pressure",
              time: "15 min ago",
              value: "2.726",
            ),
            sensorTile(
              icon: Icons.water_drop,
              label: "Humidity",
              time: "15 min ago",
              value: "2.726",
            ),
            sensorTile(
              icon: Icons.blur_circular,
              label: "Vibration",
              time: "30 min ago",
              value: "1.756",
            ),
            sensorTile(
              icon: Icons.construction,
              label: "Tool wear",
              time: "15 min ago",
              value: "2.726",
            ),
            sensorTile(
              icon: Icons.rotate_right,
              label: "Rotational Speed",
              time: "15 min ago",
              value: "2.726",
            ),
            sensorTile(
              icon: Icons.auto_fix_high,
              label: "Torque",
              time: "15 min ago",
              value: "2.726",
            ),
            sensorTile(
              icon: Icons.air,
              label: "Air Temperature",
              time: "15 min ago",
              value: "2.726",
            ),
            sensorTile(
              icon: Icons.local_fire_department,
              label: "Process Temperature",
              time: "15 min ago",
              value: "2.726",
            ),
          ],
        ),
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
