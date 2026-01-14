import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/auth_service.dart';
import '../Models/failure_model.dart';

// Data model for failure items
class FailureItem {
  final String id;
  final String machineCode;
  final DateTime timestamp;
  final String description;
  final String status; // 'open', 'critical', 'fixed'
  final String assignedTo;

  FailureItem({
    required this.id,
    required this.machineCode,
    required this.timestamp,
    required this.description,
    required this.status,
    required this.assignedTo,
  });
}

class FailuresPage extends StatefulWidget {
  final bool isDarkMode;
  final String userRole; // "admin" or "engineer"
  final String userName; // Current user name for "Assigned to Me" filter

  const FailuresPage({
    super.key,
    required this.isDarkMode,
    this.userRole = 'admin',
    this.userName = 'Ali Ahmed', // Default for testing
  });

  @override
  State<FailuresPage> createState() => _FailuresPageState();
}

class _FailuresPageState extends State<FailuresPage> {
  String selectedFilter = 'All'; // 'All' or 'Critical' or 'my failures'
  bool _isLoading = true;
  String? _userEmail;
  String? _userId;
  int _loadSeq = 0; // Guards against race conditions from overlapping fetches

  // Backed by API data
  List<FailureItem> failureItems = [];

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    try {
      final me = await AuthService().getPersonalInfo();
      _userEmail = me.email;
      _userId = me.id;
    } catch (_) {}
    setState(() => _isLoading = true);
    await _fetchAllFailures();
  }

  List<FailureItem> get filteredItems {
    // The list is already loaded per filter by calling the corresponding endpoint.
    // Avoid client-side re-filtering that may hide records due to case/whitespace.
    return failureItems;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final textColorLight = widget.isDarkMode ? Colors.white70 : Colors.black54;
    final cardBg = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor =
        widget.isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5);

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
          // Header

          const SizedBox(height: 20),

          // Failure Log Header with filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Failure log',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  _buildFilterButton('All', textColor, cardBg),
                  const SizedBox(width: 8),
                  _buildFilterButton('Critical', textColor, cardBg),
                  // Show "my failures" for Engineers and Technicians
                  if (widget.userRole.toLowerCase() == 'engineer' ||
                      widget.userRole.toLowerCase() == 'technician')
                    const SizedBox(width: 8),
                  if (widget.userRole.toLowerCase() == 'engineer' ||
                      widget.userRole.toLowerCase() == 'technician')
                    _buildFilterButton('my failures', textColor, cardBg),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Failure Items List or Empty State
          if (filteredItems.isNotEmpty)
            ...filteredItems.map((item) => _buildFailureCard(
                  item,
                  textColor,
                  textColorLight,
                  cardBg,
                ))
          else if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 40,
                      color: widget.isDarkMode ? Colors.white24 : Colors.black26),
                  const SizedBox(height: 12),
                  Text(
                    'No failures found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedFilter == 'Critical'
                        ? 'There are no critical failures right now.'
                        : selectedFilter == 'my failures'
                            ? (widget.userRole.toLowerCase() == 'technician'
                                ? 'You have no assigned failures yet.'
                                : 'You have no reported failures yet.')
                            : 'Try refreshing or changing filters.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textColorLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ],
          ),
          if (_isLoading)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(
                color: const Color(0xFFFF9800),
                backgroundColor:
                    widget.isDarkMode ? Colors.white12 : Colors.black12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, Color textColor, Color cardBg) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          _isLoading = true;
        });
        if (label == 'my failures' && _userEmail != null) {
          if (widget.userRole.toLowerCase() == 'technician') {
            _fetchAssignedFailures(_userEmail!);
          } else {
            _fetchMyFailures(_userEmail!);
          }
        } else if (label == 'Critical') {
          _fetchCriticalFailures();
        } else {
          _fetchAllFailures();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF9800)
              : (widget.isDarkMode ? Colors.white12 : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }

  // Method to show status update dialog (for Engineers/Technicians in my failures filter)
  void _showStatusUpdateDialog(
      FailureItem item, Color cardBg, Color textColor) {
    // Sample engineers list - replace with backend data
    final List<String> engineers = [
      'Ahmed Hassan',
      'Sara Mohamed',
      'Ali Ahmed',
      'Omar Khaled',
      'Fatima Ali',
    ];

    // Default to current assignment only if it's in the engineers list
    String? selectedEngineer = engineers.contains(item.assignedTo)
      ? item.assignedTo
      : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Update Status',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Change status for ${item.machineCode}',
                      style:
                          GoogleFonts.poppins(color: textColor, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    _buildStatusOption('Open', Colors.orange, item, cardBg),
                    const SizedBox(height: 12),
                    _buildStatusOption('Critical', Colors.red, item, cardBg),
                    const SizedBox(height: 12),
                    _buildStatusOption('Fixed', Colors.green, item, cardBg),

                    // Show engineer assignment dropdown for Technicians only
                    if (widget.userRole.toLowerCase() == 'technician') ...[
                      const SizedBox(height: 24),
                      Divider(color: textColor.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Assign to Engineer',
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.white12
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF9800),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedEngineer,
                            isExpanded: true,
                            dropdownColor: cardBg,
                            style: GoogleFonts.poppins(
                                color: textColor, fontSize: 14),
                            icon: Icon(Icons.arrow_drop_down, color: textColor),
                            hint: Text(
                              'Select engineer',
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 14,
                              ),
                            ),
                            items: engineers.map((String engineer) {
                              return DropdownMenuItem<String>(
                                value: engineer,
                                child: Text(engineer),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedEngineer = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      // Show action only after a valid selection different to current assignment
                      if (selectedEngineer != null && selectedEngineer != item.assignedTo)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              _assignToEngineer(item, selectedEngineer!);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Assign to $selectedEngineer',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build status option button in dialog
  Widget _buildStatusOption(
      String status, Color color, FailureItem item, Color cardBg) {
    final isCurrentStatus = item.status.toLowerCase() == status.toLowerCase();
    return InkWell(
      onTap: () {
        _updateFailureStatus(item, status.toLowerCase());
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isCurrentStatus ? color.withOpacity(0.2) : cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: isCurrentStatus ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCurrentStatus ? Icons.check_circle : Icons.circle_outlined,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              status,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: isCurrentStatus ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update failure status
  void _updateFailureStatus(FailureItem item, String newStatus) {
    AuthService()
        .updateFailureStatus(failureId: item.id, status: newStatus)
        .then((updated) {
      setState(() {
        final index = failureItems.indexWhere((f) => f.id == item.id);
        if (index != -1) {
          failureItems[index] = FailureItem(
            id: updated.id,
            machineCode: updated.machineName.isNotEmpty
                ? updated.machineName
                : updated.machineId,
            timestamp: updated.createdAt ?? item.timestamp,
            description: updated.description,
            status: updated.status,
            assignedTo: updated.assignedTo,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${updated.status}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  // Assign failure to engineer (Technician feature)
  void _assignToEngineer(FailureItem item, String engineerName) {
    setState(() {
      // Find the item in the list and update the assignedTo field
      final index = failureItems.indexWhere((f) => f.id == item.id);
      if (index != -1) {
        failureItems[index] = FailureItem(
          id: item.id,
          machineCode: item.machineCode,
          timestamp: item.timestamp,
          description: item.description,
          status: item.status,
          assignedTo: engineerName, // Update assignment
        );
      }
    });

    // TODO: Send assignment to backend
    // Example:
    // await FailureService().assignFailureToEngineer(
    //   failureId: item.id,
    //   engineerName: engineerName,
    // );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assigned to $engineerName'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFailureCard(
    FailureItem item,
    Color textColor,
    Color textColorLight,
    Color cardBg,
  ) {
    // Determine border color and status badge color
    Color borderColor;
    Color statusBgColor;
    Color statusTextColor;
    String statusText;

    switch (item.status) {
      case 'open':
        borderColor = Colors.orange;
        statusBgColor = Colors.orange.withOpacity(0.1);
        statusTextColor = Colors.orange;
        statusText = 'Open';
        break;
      case 'critical':
        borderColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        statusTextColor = Colors.red;
        statusText = 'Critical';
        break;
      case 'fixed':
        borderColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        statusTextColor = Colors.green;
        statusText = 'Fixed';
        break;
      default:
        borderColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.1);
        statusTextColor = Colors.grey;
        statusText = 'Unknown';
    }

    // Make card tappable for Engineers AND Technicians in 'my failures' filter
    final isClickable = (widget.userRole.toLowerCase() == 'engineer' ||
            widget.userRole.toLowerCase() == 'technician') &&
        selectedFilter == 'my failures';

    final cardWidget = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.machineCode,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusTextColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${item.machineCode} ${_formatTimestamp(item.timestamp)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textColorLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: textColorLight),
                const SizedBox(width: 4),
                Text(
                  item.assignedTo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textColorLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Wrap in GestureDetector if Engineer/Technician viewing my failures
    return isClickable
        ? GestureDetector(
            onTap: () => _showStatusUpdateDialog(item, cardBg, textColor),
            child: cardWidget,
          )
        : cardWidget;
  }

  String _formatTimestamp(DateTime timestamp) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    final month = months[timestamp.month - 1];
    final day = timestamp.day;
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $hour:$minute $period';
  }

  // --- Data fetching helpers ---
  Future<void> _fetchAllFailures() async {
    final seq = ++_loadSeq;
    try {
      final list = await AuthService().getAllFailures();
      if (!mounted || seq != _loadSeq) return; // ignore stale responses
      setState(() {
        failureItems = list
            .map((f) => FailureItem(
                  id: f.id,
                  machineCode: f.machineName.isNotEmpty
                      ? f.machineName
                      : f.machineId,
                  timestamp: f.createdAt ?? DateTime.now(),
                  description: f.description,
                  status: f.status,
                  assignedTo: f.assignedTo,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || seq != _loadSeq) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load failures: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchMyFailures(String email) async {
    final seq = ++_loadSeq;
    try {
      final list = await AuthService().getFailuresByReporter(email);
      if (!mounted || seq != _loadSeq) return;
      List<Failure> items = list;
      // Fallback: if endpoint returns empty (older records may store ReportedBy as ID),
      // fetch all and filter by either email or id.
      if (items.isEmpty) {
        try {
          final all = await AuthService().getAllFailures();
          items = all.where((f) => (f.reportedBy == _userEmail) || (f.reportedBy == _userId)).toList();
        } catch (_) {}
      }
      if (!mounted || seq != _loadSeq) return;
      setState(() {
        failureItems = items
            .map((f) => FailureItem(
                  id: f.id,
                  machineCode: f.machineName.isNotEmpty
                      ? f.machineName
                      : f.machineId,
                  timestamp: f.createdAt ?? DateTime.now(),
                  description: f.description,
                  status: f.status,
                  assignedTo: f.assignedTo,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || seq != _loadSeq) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load my failures: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchCriticalFailures() async {
    final seq = ++_loadSeq;
    try {
      final list = await AuthService().getCriticalFailures();
      if (!mounted || seq != _loadSeq) return;
      List<Failure> items = list;
      // Fallback: server may store status with different case/whitespace.
      if (items.isEmpty) {
        try {
          final all = await AuthService().getAllFailures();
          items = all.where((f) => f.status.trim().toLowerCase() == 'critical').toList();
        } catch (_) {}
      }
      if (!mounted || seq != _loadSeq) return;
      setState(() {
        failureItems = items
            .map((f) => FailureItem(
                  id: f.id,
                  machineCode: f.machineName.isNotEmpty
                      ? f.machineName
                      : f.machineId,
                  timestamp: f.createdAt ?? DateTime.now(),
                  description: f.description,
                  status: f.status,
                  assignedTo: f.assignedTo,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || seq != _loadSeq) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load critical failures: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchAssignedFailures(String email) async {
    final seq = ++_loadSeq;
    try {
      final list = await AuthService().getFailuresAssignedTo(email);
      if (!mounted || seq != _loadSeq) return;
      List<Failure> items = list;
      // Fallback: older records might store AssignedTo as ID
      if (items.isEmpty) {
        try {
          final all = await AuthService().getAllFailures();
          items = all.where((f) => (f.assignedTo == _userEmail) || (f.assignedTo == _userId)).toList();
        } catch (_) {}
      }
      if (!mounted || seq != _loadSeq) return;
      setState(() {
        failureItems = items
            .map((f) => FailureItem(
                  id: f.id,
                  machineCode: f.machineName.isNotEmpty
                      ? f.machineName
                      : f.machineId,
                  timestamp: f.createdAt ?? DateTime.now(),
                  description: f.description,
                  status: f.status,
                  assignedTo: f.assignedTo,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || seq != _loadSeq) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load assigned failures: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
