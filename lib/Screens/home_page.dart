import 'package:flutter/material.dart';
import 'package:fpms_app/Screens/analytics_page.dart';
import 'package:fpms_app/Screens/overview_page.dart';
import 'package:fpms_app/Screens/weekly_page.dart';
import 'package:fpms_app/Screens/Profile/profile_screen.dart'; // Import Profile Screen
import 'package:google_fonts/google_fonts.dart';
import 'package:fpms_app/core/constants/app_colors.dart'; // Import colors for the button

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int bottomIndex = 0;
  int topTabIndex = 0; // 0 Overview, 1 Weekly, 2 Analytic

  // Theme State
  bool isDarkMode = true; // Default is Dark

  final pages = [
    'Overview',
    'Weekly',
    'Analytic',
  ];

  void _toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final backgroundColor = isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5);
    final bottomNavBg = isDarkMode ? const Color(0xFF0F0F0F) : Colors.white;
    final bottomNavSelected = const Color(0xFFFF9800);
    final bottomNavUnselected = isDarkMode ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      // Header + content
      body: SafeArea(
        child: IndexedStack(
          index: bottomIndex,
          children: [
            // Index 0: Home Content
            _buildHomeContent(),

            // Index 1: Dashboard (Placeholder)
            Center(
                child: Text(
                    "Dashboard",
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                    )
                )
            ),

            // Index 2: Profile Screen
            // We pass the state and the function down to the profile
            ProfileScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: _toggleTheme,
            ),
          ],
        ),
      ),

      // === UPDATED FAB: Pass isDarkMode ===
      floatingActionButton: bottomIndex == 0 
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryOrange,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () {
                Navigator.pushNamed(context, '/add-machine', arguments: {
                  'isDarkMode': isDarkMode, // <--- Added this line
                });
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null, 

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        backgroundColor: bottomNavBg,
        selectedItemColor: bottomNavSelected,
        unselectedItemColor: bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => bottomIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.widgets_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // Main home layout
  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        // Segmented tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildSegmentedControl(),
        ),
        const SizedBox(height: 12),
        // Page body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IndexedStack(
              index: topTabIndex,
              children: const [
                OverviewPage(),
                WeeklyPage(),
                AnalyticsPage(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A00), Color(0xFF5C2CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          // Worker image placeholder (circular)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.engineering_rounded,
                size: 44, color: Colors.white),
          ),
          const SizedBox(width: 12),
          // Text area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Back",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text("Your Machine\nOur Priority !",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text("start now and take better care of your Machine",
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          // small menu icon
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white70),
          )
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final containerColor = isDarkMode ? const Color(0xFF111111) : Colors.grey[200];
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey[300]!;
    final selectedBg = isDarkMode ? const Color(0xFF0F0F0F).withOpacity(0.2) : Colors.white;
    final unselectedText = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: List.generate(pages.length, (i) {
          final selected = i == topTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => topTabIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? selectedBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected && !isDarkMode ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                ),
                child: Center(
                  child: Text(
                    pages[i],
                    style: GoogleFonts.poppins(
                      color: selected
                          ? const Color(0xFFFF9800)
                          : unselectedText,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
