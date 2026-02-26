import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpms_app/core/constants/app_colors.dart';
import '../../Services/auth_service.dart';
import '../../Models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = await _authService.getPersonalInfo();

      if (mounted) {
        setState(() {
          _user = user;
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

  Future<void> _logout() async {
    // Show confirmation dialog first
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final message = await _authService.logout();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to login and clear all routes
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });

        // Still navigate to login even if API fails (token is cleared locally)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out locally: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine text colors based on the PASSED theme
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subTextColor =
        widget.isDarkMode ? Colors.white70 : AppColors.textGrey;
    final cardColor =
        widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading profile',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _error!,
                            style: TextStyle(fontSize: 14, color: subTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                    'assets/images/onboarding_1.png'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _user?.fullName ?? 'Loading...',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _user?.email ?? 'Loading...',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _user?.role ?? 'Loading...',
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.white),
                                onPressed: () {
                                  if (_user != null) {
                                    Navigator.pushNamed(
                                        context, '/edit-profile',
                                        arguments: {
                                          'name': _user!.fullName,
                                          'email': _user!.email,
                                          // === FIX 1: PASS THE THEME STATE ===
                                          'isDarkMode': widget.isDarkMode,
                                        });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: "My Account",
                          subtitle: "Make changes to your account",
                          showWarning: true,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          cardColor: cardColor,
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: "Change Password",
                          subtitle: "Change Your password",
                          textColor: textColor,
                          subTextColor: subTextColor,
                          cardColor: cardColor,
                          onTap: () {
                            Navigator.pushNamed(context, '/change-password',
                                arguments: {
                                  // === FIX 1: PASS THE THEME STATE ===
                                  'isDarkMode': widget.isDarkMode,
                                });
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.dark_mode_outlined,
                          title: "Dark/Light Mode",
                          subtitle: "Manage Your Interface",
                          isSwitch: true,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          cardColor: cardColor,
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: "Log out",
                          subtitle: _isLoggingOut
                              ? "Logging out..."
                              : "Securely log out of account",
                          isLogout: true,
                          isLoading: _isLoggingOut,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          cardColor: cardColor,
                          onTap: _isLoggingOut ? null : _logout,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "More",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const SizedBox(height: 10),
                        _buildSimpleMenuItem(
                            icon: Icons.help_outline,
                            title: "Help & Support",
                            textColor: textColor,
                            cardColor: cardColor),
                        _buildSimpleMenuItem(
                            icon: Icons.favorite_border,
                            title: "About App",
                            textColor: textColor,
                            cardColor: cardColor),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showWarning = false,
    bool isSwitch = false,
    bool isLogout = false,
    bool isLoading = false,
    required Color textColor,
    required Color subTextColor,
    required Color cardColor,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isSwitch ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isLogout ? const Color(0xFFFFF5F5) : AppColors.lightOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isLogout ? Colors.red : AppColors.iconOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (showWarning)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.warning_amber_rounded,
                    color: AppColors.redAlert, size: 20),
              ),
            if (isSwitch)
              CupertinoSwitch(
                value: widget.isDarkMode,
                activeTrackColor: AppColors.primaryOrange,
                onChanged: widget.onThemeChanged,
              )
            else if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleMenuItem({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color cardColor,
  }) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.lightOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.iconOrange, size: 20),
            ),
            const SizedBox(width: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ));
  }
}
