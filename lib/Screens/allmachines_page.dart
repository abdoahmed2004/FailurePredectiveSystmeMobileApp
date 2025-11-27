import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fpms_app/Screens/machine_details_page.dart';

class AllMachinesPage extends StatelessWidget {
  const AllMachinesPage({super.key});

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
                    onTap: () => Navigator.pushNamed(context, '/add-machine'),
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
              Row(
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
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                    
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      "10 Machines",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Machines list (scrollable)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    machineCard(
                      context: context,
                      color: const Color(0xFF2E2E2E),
                      status: "Inactive",
                      mc: "MC1",
                      detail: "Temperature fault",
                      detailColor: Colors.red,
                      operator: "Daniel Hook",
                      email: "dhook@gmail.com",
                      statusDot: Colors.red,
                    ),

                    machineCard(
                      context: context,
                      color: const Color(0xFF0057FF),
                      status: "Active",
                      mc: "MC2",
                      detail: "Working",
                      detailColor: Colors.greenAccent,
                      operator: "Jasan Mak",
                      email: "djasanmank@gmail.com",
                      statusDot: Colors.greenAccent,
                    ),

                    machineCard(
                      context: context,
                      color: const Color(0xFF2E2E2E),
                      status: "Under Maintenance",
                      mc: "MC3",
                      detail: "Being Fixed",
                      detailColor: Colors.orange,
                      operator: "Mak Kalan",
                      email: "mkdlasank@gmail.com",
                      statusDot: Colors.orange,
                    ),

                    // -------- Add More Machines (4 to 9) --------
                    machineCard(
                      context: context,
                      color: const Color(0xFF2E2E2E),
                      status: "Inactive",
                      mc: "MC4",
                      detail: "Motor Overheated",
                      detailColor: Colors.redAccent,
                      operator: "Tom Hardy",
                      email: "tom@gmail.com",
                      statusDot: Colors.redAccent,
                    ),

                    machineCard(
                      context: context,
                      color: const Color(0xFF0080FF),
                      status: "Active",
                      mc: "MC5",
                      detail: "Running Smooth",
                      detailColor: Colors.lightGreen,
                      operator: "John Max",
                      email: "johnmax@gmail.com",
                      statusDot: Colors.green,
                    ),

                    machineCard(
                      context: context,
                      color: const Color(0xFF2E2E2E),
                      status: "Under Maintenance",
                      mc: "MC6",
                      detail: "Replacing Parts",
                      detailColor: Colors.orangeAccent,
                      operator: "Sarah Lin",
                      email: "sarah@gmail.com",
                      statusDot: Colors.orangeAccent,
                    ),

                    machineCard(
                      context: context,
                      color: const Color(0xFF7A00FF),
                      status: "Active",
                      mc: "MC7",
                      detail: "Production High",
                      detailColor: Colors.greenAccent,
                      operator: "Kevin Doe",
                      email: "kevin@gmail.com",
                      statusDot: Colors.greenAccent,
                    ),

                    machineCard(
                      context: context,
                      color: const Color(0xFF2E2E2E),
                      status: "Inactive",
                      mc: "MC8",
                      detail: "No Power",
                      detailColor: Colors.red,
                      operator: "Henry Ford",
                      email: "henry@gmail.com",
                      statusDot: Colors.red,
                    ),

                    machineCard(
                      context: context,
                      color: const Color(0xFFFF6400),
                      status: "Active",
                      mc: "MC9",
                      detail: "Optimal Mode",
                      detailColor: Colors.white,
                      operator: "Liam D.",
                      email: "liamd@gmail.com",
                      statusDot: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                    builder: (_) => MachineDetailsPage(machineName: mc),
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

