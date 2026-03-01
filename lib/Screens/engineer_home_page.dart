import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fpms_app/core/theme/app_theme.dart';
import 'package:fpms_app/core/theme/theme_controller.dart';

import '../Services/auth_service.dart';
import '../Models/user_model.dart';
import '../Models/machine_model.dart';
import '../Models/failure_model.dart';
import 'Profile/profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  EngineerHomePage – root scaffold with bottom nav
// ─────────────────────────────────────────────────────────────────────────────
class EngineerHomePage extends StatefulWidget {
  final String userName;
  const EngineerHomePage({super.key, this.userName = 'Engineer'});

  @override
  State<EngineerHomePage> createState() => _EngineerHomePageState();
}

class _EngineerHomePageState extends State<EngineerHomePage> {
  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cs.surface,
      body: SafeArea(
        child: IndexedStack(
          index: _bottomIndex,
          children: [
            _EngineerMainContent(userName: widget.userName),
            const Center(
                child: _PlaceholderTab(
                    icon: Icons.smart_toy_outlined, label: 'Chatbot')),
            const Center(
                child: _PlaceholderTab(
                    icon: Icons.schedule_outlined, label: 'Reports')),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': 'assets/images/home.png', 'label': 'Home'},
      {'icon': 'assets/images/chatai.png', 'label': 'Chatbot'},
      {'icon': 'assets/images/circleicon.png', 'label': 'Reports'},
      {'icon': 'assets/images/profileicon.png', 'label': 'Profile'},
    ];

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cs.surface,
        border: Border(top: BorderSide(color: context.cs.outline)),
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == _bottomIndex;
          final iconPath = items[i]['icon'] as String;
          final label = items[i]['label'] as String;

          return GestureDetector(
            onTap: () => setState(() => _bottomIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: Color(0xFF5C3A9E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Image.asset(iconPath,
                            width: 20, height: 20, color: Colors.white),
                        SizedBox(width: 6),
                        Text(label,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else
                  Image.asset(iconPath,
                      width: 24,
                      height: 24,
                      color: context.cs.onSurfaceVariant),
                if (selected) ...[
                  const SizedBox(height: 3),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                  ),
                ]
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main content
// ─────────────────────────────────────────────────────────────────────────────
class _EngineerMainContent extends StatefulWidget {
  final String userName;
  const _EngineerMainContent({required this.userName});

  @override
  State<_EngineerMainContent> createState() => _EngineerMainContentState();
}

class _EngineerMainContentState extends State<_EngineerMainContent> {
  int _tabIndex = 1; // 0=Overview, 1=Weekly, 2=Failures

  List<Machine> _machines = [];
  List<Failure> _failures = [];
  bool _loadingMachines = false;
  bool _loadingFailures = false;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  void _showReportSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportFailureSheet(
        preloadedMachines: _machines,
        onSuccess: _fetchAll,
      ),
    );
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loadingMachines = true;
      _loadingFailures = true;
    });
    try {
      final m = await AuthService().getAllMachines();
      if (mounted) setState(() => _machines = m);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMachines = false);
    }
    try {
      final f = await AuthService().getAllFailures();
      if (mounted) setState(() => _failures = f);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingFailures = false);
    }
  }

  String get _headerTitle {
    switch (_tabIndex) {
      case 2:
        return 'Failure Overview';
      default:
        return 'Welcome Back';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFailures = _tabIndex == 2;

    return Stack(
      children: [
        Column(
          children: [
            // ── Gradient header ────────────────────────────────────────────
            _buildHeader(isFailures),
            // ── White body ─────────────────────────────────────────────────
            Expanded(
              child: Container(
                color: context.cs.surface,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    _buildTabBar(),
                    const SizedBox(height: 14),
                    Expanded(child: _buildTabBody()),
                  ],
                ),
              ),
            ),
          ],
        ),

        // FAB – only on Failures tab
        if (isFailures)
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: Color(0xFF5C3A9E),
              elevation: 6,
              shape: CircleBorder(),
              onPressed: () => _showReportSheet(context),
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isFailures) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E1F5E), Color(0xFF4A3080)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Top bar: grid icon | title | three dots
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Row(
              children: [
                Icon(Icons.grid_view_rounded, color: Colors.white70, size: 22),
                Expanded(
                  child: Center(
                    child: Text(
                      _headerTitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.white70, size: 22),
              ],
            ),
          ),

          // Body of header: banner card OR chart card
          if (isFailures) _buildChartCard() else _buildBannerCard(),
        ],
      ),
    );
  }

  // ── Orange banner card ──────────────────────────────────────────────────────
  Widget _buildBannerCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFC97A30), Color(0xFFE8A84C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cs.surface.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              child: Image.asset(
                'assets/images/Engineer icon.png',
                width: 130,
                height: 150,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  width: 130,
                  height: 150,
                  color: Colors.transparent,
                  child: const Icon(Icons.engineering,
                      color: Colors.white54, size: 60),
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            left: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Machine\nOur Priority !',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'start now and take better\ncare of your business',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Failure line chart card ─────────────────────────────────────────────────
  Widget _buildChartCard() {
    // Group real failures by month index (0..6 for Jun..Dec)
    final monthLabels = ['JUN', 'JULY', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final monthIndices = [6, 7, 8, 9, 10, 11, 12]; // 1-indexed months
    final counts = monthIndices.map((m) {
      return _failures
          .where((f) => f.createdAt != null && f.createdAt!.month == m)
          .length
          .toDouble();
    }).toList();

    // Fallback sample data if no real data
    final chartData =
        _failures.isEmpty ? [5.0, 12.0, 8.0, 18.0, 22.0, 15.0, 10.0] : counts;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: "Failures" label + count | "Monthly" dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Failures',
                      style: GoogleFonts.poppins(
                          color: context.cs.onSurfaceVariant, fontSize: 12)),
                  Text(
                    '${_failures.isEmpty ? 23 : _failures.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.cs.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: context.cs.outline),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text('Monthly',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: context.cs.onSurfaceVariant)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 14, color: context.cs.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Line chart
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _LineChartPainter(data: chartData),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          // Month labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthLabels
                .map((m) => Text(m,
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: context.cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500)))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final tabs = ['Overview', 'Weekly', 'Analytic'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border:
                      selected ? Border.all(color: context.cs.outline) : null,
                  boxShadow: selected
                      ? [
                          const BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected
                          ? Color(0xFF5C3A9E)
                          : context.cs.onSurfaceVariant,
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

  // ── Tab body ────────────────────────────────────────────────────────────────
  Widget _buildTabBody() {
    switch (_tabIndex) {
      case 0:
        return _OverviewTab(machines: _machines, loading: _loadingMachines);
      case 1:
        return const _WeeklyCalendarTab();
      case 2:
        return _FailuresTab(
          failures: _failures,
          loading: _loadingFailures,
          onRefresh: _fetchAll,
        );
      default:
        return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Line chart custom painter
// ─────────────────────────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  const _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(max).clamp(1.0, double.infinity);
    final minVal = 0.0;
    final range = maxVal - minVal;

    // Y-axis grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF8F8F8)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = size.height * (1 - i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Compute points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height * (1 - (data[i] - minVal) / range);
      points.add(Offset(x, y));
    }

    // Filled area under the line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF5C6BC0).withOpacity(0.22),
          const Color(0xFF5C6BC0).withOpacity(0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF5C6BC0)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 =
          Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots on each point
    final dotPaint = Paint()..color = const Color(0xFF5C6BC0);
    final dotOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotOutline);
    }

    // Tooltip on the highest point
    final peakIdx = data.indexOf(data.reduce(max));
    final peakPt = points[peakIdx];
    _drawTooltip(canvas, peakPt, '${data[peakIdx].toInt()}');
  }

  void _drawTooltip(Canvas canvas, Offset pt, String label) {
    const tw = 52.0;
    const th = 26.0;
    const r = 8.0;
    const triH = 7.0;

    final left = (pt.dx - tw / 2).clamp(0.0, double.infinity);
    final top = pt.dy - th - triH - 6;

    // Background pill
    final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, tw, th), const Radius.circular(r));
    canvas.drawRRect(rRect, Paint()..color = const Color(0xFF2E2E4A));

    // Triangle pointer
    final tri = Path()
      ..moveTo(pt.dx - 6, top + th)
      ..lineTo(pt.dx + 6, top + th)
      ..lineTo(pt.dx, top + th + triH)
      ..close();
    canvas.drawPath(tri, Paint()..color = Color(0xFF2E2E4A));

    // Text
    final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas, Offset(left + (tw - tp.width) / 2, top + (th - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => old.data != data;
}

// ─────────────────────────────────────────────────────────────────────────────
//  FAILURES TAB
// ─────────────────────────────────────────────────────────────────────────────
class _FailuresTab extends StatefulWidget {
  final List<Failure> failures;
  final bool loading;
  final Future<void> Function() onRefresh;

  const _FailuresTab({
    required this.failures,
    required this.loading,
    required this.onRefresh,
  });

  @override
  State<_FailuresTab> createState() => _FailuresTabState();
}

class _FailuresTabState extends State<_FailuresTab> {
  // 0 = All, 1 = Critical, 2 = Requested (open)
  int _filterIndex = 0;

  List<Failure> get _filtered {
    switch (_filterIndex) {
      case 1: // Critical
        return widget.failures
            .where((f) => f.severityLevel.toLowerCase() == 'critical')
            .toList();
      case 2: // Requested = open
        return widget.failures.where((f) => f.status == 'open').toList();
      default:
        return widget.failures;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF5C3A9E)));
    }

    return RefreshIndicator(
      color: Color(0xFF5C3A9E),
      onRefresh: widget.onRefresh,
      child: Column(
        children: [
          // ── "Failure log" header + filter pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Failure log',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.cs.onSurface,
                  ),
                ),
                const Spacer(),
                _filterPill('All', 0),
                const SizedBox(width: 6),
                _filterPill('Critical', 1),
                const SizedBox(width: 6),
                _filterPill('Requested', 2),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Failure cards
          Expanded(
            child: _filtered.isEmpty
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(
                            'No failures found',
                            style: GoogleFonts.poppins(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _FailureCard(failure: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill(String label, int idx) {
    final selected = _filterIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = idx),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF2E2E4A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Color(0xFF2E2E4A) : context.cs.outline,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : context.cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Individual Failure card
// ─────────────────────────────────────────────────────────────────────────────
class _FailureCard extends StatelessWidget {
  final Failure failure;
  const _FailureCard({required this.failure});

  @override
  Widget build(BuildContext context) {
    // Left border color + badge color based on status / severity
    Color borderColor;
    Color badgeColor;
    String badgeLabel;

    final status = failure.status.toLowerCase();
    final severity = failure.severityLevel.toLowerCase();

    if (status == 'fixed') {
      borderColor = const Color(0xFF2ECC71);
      badgeColor = const Color(0xFF2ECC71);
      badgeLabel = 'Fixed';
    } else if (severity == 'critical' || status == 'critical') {
      borderColor = const Color(0xFFE53935);
      badgeColor = const Color(0xFFE53935);
      badgeLabel = 'Critical';
    } else {
      // open / medium / low
      borderColor = const Color(0xFFFF9800);
      badgeColor = const Color(0xFFFF9800);
      badgeLabel = _capitalize(status == 'open' ? 'Open' : status);
    }

    // Format date
    final dateStr =
        failure.createdAt != null ? _formatDate(failure.createdAt!) : '';

    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Failure ID + badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${failure.id.length > 6 ? failure.id.substring(failure.id.length - 6).toUpperCase() : failure.id.toUpperCase()}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.cs.onSurface,
                    ),
                  ),
                ),
                _BadgePill(label: badgeLabel, color: badgeColor),
              ],
            ),
            SizedBox(height: 2),
            // ── Row 2: Machine ID + datetime
            Text(
              '${failure.machineId}${dateStr.isNotEmpty ? '   $dateStr' : ''}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: context.cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // ── Description
            Text(
              failure.description.isNotEmpty
                  ? failure.description
                  : 'No description provided.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: context.cs.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            // ── Bottom row: assigned person + resolve button
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 15, color: context.cs.onSurfaceVariant),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    failure.assignedTo.isNotEmpty
                        ? failure.assignedTo.split('@').first
                        : 'Unassigned',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showResolveDialog(context, failure),
                  child: Row(
                    children: [
                      Text(
                        'Resolve',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Color(0xFF5C3A9E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 16, color: Color(0xFF5C3A9E)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResolveDialog(BuildContext context, Failure f) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ResolveSheet(failure: f),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
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
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month]} ${dt.day}, $h:$m $period';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Badge pill widget
// ─────────────────────────────────────────────────────────────────────────────
class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;
  const _BadgePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Resolve bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ResolveSheet extends StatefulWidget {
  final Failure failure;
  const _ResolveSheet({required this.failure});

  @override
  State<_ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<_ResolveSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService()
          .updateFailureStatus(failureId: widget.failure.id, status: newStatus);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Status',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Machine: ${widget.failure.machineId}',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 10),
          ],
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: Color(0xFF5C3A9E)))
          else
            Row(
              children: [
                Expanded(
                  child: _sheetBtn('Mark Fixed', const Color(0xFF2ECC71),
                      () => _updateStatus('fixed')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _sheetBtn('Mark Open', const Color(0xFFFF9800),
                      () => _updateStatus('open')),
                ),
              ],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sheetBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Report Failure bottom sheet  (matches the design mockup exactly)
// ─────────────────────────────────────────────────────────────────────────────
class _ReportFailureSheet extends StatefulWidget {
  final List<Machine> preloadedMachines;
  final Future<void> Function() onSuccess;

  const _ReportFailureSheet({
    required this.preloadedMachines,
    required this.onSuccess,
  });

  @override
  State<_ReportFailureSheet> createState() => _ReportFailureSheetState();
}

class _ReportFailureSheetState extends State<_ReportFailureSheet> {
  final _machineNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String? _selectedMachineId; // Mongo _id
  String? _selectedAssignee; // technician email
  double _severityLevel = 1.0; // 0=Low, 1=Normal, 2=Critical

  List<User> _technicians = [];
  bool _loadingTech = true;
  bool _submitting = false;
  String? _error;

  // derived from selected machine
  String _machineName = '';
  String _machineType = '';

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  @override
  void dispose() {
    _machineNameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTechnicians() async {
    try {
      final list = await AuthService().getTechnicians();
      if (mounted) {
        setState(() {
          _technicians = list
              .where((u) => u.fullName.isNotEmpty && u.fullName != 'N/A')
              .toList();
          _loadingTech = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTech = false);
    }
  }

  String _severityText() {
    if (_severityLevel <= 0.5) return 'Low';
    if (_severityLevel <= 1.5) return 'Normal';
    return 'Critical';
  }

  String _severityForApi() {
    if (_severityLevel <= 0.5) return 'low';
    if (_severityLevel <= 1.5) return 'medium';
    return 'critical';
  }

  Color _severityColor() {
    if (_severityLevel <= 0.5) return const Color(0xFF4CAF50);
    if (_severityLevel <= 1.5) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  Future<void> _submit() async {
    if (_selectedMachineId == null) {
      setState(() => _error = 'Please select a machine');
      return;
    }
    if (_descriptionCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a description');
      return;
    }
    if (_selectedAssignee == null) {
      setState(() => _error = 'Please select an assignee');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final me = await AuthService().getPersonalInfo();
      await AuthService().createFailureReport(
        machineName: _machineName.isNotEmpty
            ? _machineName
            : _machineNameCtrl.text.trim(),
        machineType: _machineType.isNotEmpty ? _machineType : 'Unknown',
        machineId: _selectedMachineId!,
        description: _descriptionCtrl.text.trim(),
        assignedTo: _selectedAssignee!,
        severity: _severityForApi(),
        assignedBy: me.email,
      );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        await widget.onSuccess();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failure reported successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),

            // ── Title
            Text('Report failure',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.cs.onSurface)),
            Text('Log a new incident for a machine',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: context.cs.onSurfaceVariant)),
            Divider(height: 24, color: context.cs.outline),

            // ── Machine Name (full width)
            _label('Machine Name'),
            const SizedBox(height: 6),
            _textField(
              controller: _machineNameCtrl,
              hint: 'e.g. Hydraulic Press',
              enabled: _selectedMachineId == null,
            ),
            const SizedBox(height: 14),

            // ── Machine ID + Description (side by side)
            Row(
              children: [
                // Machine ID dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Machine ID'),
                      const SizedBox(height: 6),
                      _machineDropdown(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Description'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _descriptionCtrl, hint: 'What happened?'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Assign To (half width)
            _label('Assign To'),
            const SizedBox(height: 6),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 30,
              child: _assignDropdown(),
            ),
            SizedBox(height: 20),

            // ── Severity slider
            Text('Severity level',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.cs.onSurface)),
            SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _severityColor(),
                inactiveTrackColor: context.cs.outline,
                thumbColor: _severityColor(),
                overlayColor: _severityColor().withOpacity(0.15),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              ),
              child: Slider(
                value: _severityLevel,
                min: 0,
                max: 2,
                divisions: 2,
                onChanged: (v) => setState(() => _severityLevel = v),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Low', 'Normal', 'Critical'].map((s) {
                  final active = _severityText() == s;
                  final c =
                      active ? _severityColor() : context.cs.onSurfaceVariant;
                  return Text(s,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: c,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w400));
                }).toList(),
              ),
            ),

            // ── Error message
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: GoogleFonts.poppins(
                      color: Color(0xFFE53935), fontSize: 12)),
            ],

            const SizedBox(height: 24),

            // ── Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9800),
                  disabledBackgroundColor: Color(0xFFFF9800).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _submitting
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: context.cs.surface, strokeWidth: 2.5))
                    : Icon(Icons.save_rounded, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontSize: 12,
          color: context.cs.onSurfaceVariant,
          fontWeight: FontWeight.w500));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: GoogleFonts.poppins(fontSize: 13, color: context.cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 12, color: context.cs.onSurfaceVariant),
        filled: true,
        fillColor: context.cs.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.cs.outline)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.cs.outline)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFFFF9800), width: 1.5)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.cs.outline)),
      ),
    );
  }

  Widget _machineDropdown() {
    final machines = widget.preloadedMachines;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.cs.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMachineId,
          hint: Text('Select',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: context.cs.onSurfaceVariant)),
          isExpanded: true,
          dropdownColor: context.cs.surface,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 18, color: Color(0xFF777777)),
          style: GoogleFonts.poppins(fontSize: 12, color: context.cs.onSurface),
          items: machines
              .map((m) => DropdownMenuItem<String>(
                    value: m.id ?? m.machineId,
                    child: Text(m.machineId),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedMachineId = val;
              final m = machines.firstWhere((m) => (m.id ?? m.machineId) == val,
                  orElse: () => machines.first);
              _machineName = m.machineModel;
              _machineType = m.machineType;
              _machineNameCtrl.text = m.machineModel;
            });
          },
        ),
      ),
    );
  }

  Widget _assignDropdown() {
    if (_loadingTech) {
      return const SizedBox(
        height: 44,
        child: Center(
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.cs.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAssignee,
          hint: Text('Select',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: context.cs.onSurfaceVariant)),
          isExpanded: true,
          dropdownColor: context.cs.surface,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 18, color: Color(0xFF777777)),
          style: GoogleFonts.poppins(fontSize: 12, color: context.cs.onSurface),
          items: _technicians
              .map((u) => DropdownMenuItem<String>(
                    value: u.email,
                    child: Text(u.fullName, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedAssignee = v),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyCalendarTab extends StatefulWidget {
  const _WeeklyCalendarTab();

  @override
  State<_WeeklyCalendarTab> createState() => _WeeklyCalendarTabState();
}

class _WeeklyCalendarTabState extends State<_WeeklyCalendarTab> {
  late DateTime _weekStart;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _weekStart = _sundayOf(_today);
  }

  DateTime _sundayOf(DateTime d) => d.subtract(Duration(days: d.weekday % 7));

  void _prev() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _next() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  String _monthLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (_weekStart.month == end.month) {
      return '${months[_weekStart.month]} ${_weekStart.year}';
    }
    return '${months[_weekStart.month]} – ${months[end.month]} ${end.year}';
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      physics: BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.cs.outline),
            boxShadow: [
              BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month + arrows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_monthLabel(),
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.cs.onSurface)),
                  Row(children: [
                    _arrowBtn(Icons.chevron_left, _prev),
                    const SizedBox(width: 6),
                    _arrowBtn(Icons.chevron_right, _next),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              // Day labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: dayLabels.asMap().entries.map((e) {
                  final d = _weekStart.add(Duration(days: e.key));
                  final isToday = _same(d, _today);
                  return SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(e.value,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isToday
                                  ? Color(0xFFFF9800)
                                  : context.cs.onSurfaceVariant)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Date numbers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final day = _weekStart.add(Duration(days: i));
                  final isToday = _same(day, _today);
                  return Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: isToday
                            ? BoxDecoration(
                                color: Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(20))
                            : null,
                        child: Center(
                          child: Text(
                            '${day.day}'.padLeft(2, '0'),
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.w400,
                                color: isToday
                                    ? Colors.white
                                    : context.cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isToday)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF9800), shape: BoxShape.circle),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.cs.outline),
            color: context.cs.surface),
        child: Icon(icon, size: 18, color: Color(0xFF777777)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final List<Machine> machines;
  final bool loading;
  const _OverviewTab({required this.machines, required this.loading});

  // ── Computed stats from real data ──────────────────────────────────────────
  int get _total => machines.length;
  int get _activeCount =>
      machines.where((m) => m.status == 0).length; // 0 = working
  int get _faultCount =>
      machines.where((m) => m.status == 1).length; // 1 = fault/maintenance
  int get _inactiveCount => _total - _activeCount - _faultCount;

  double get _activePct => _total == 0 ? 0 : _activeCount / _total;
  double get _faultPct => _total == 0 ? 0 : _faultCount / _total;
  double get _inactivePct => _total == 0 ? 0 : _inactiveCount / _total;

  // Performance = active ratio as a display percentage
  String get _perfLabel {
    if (_total == 0) return '0%';
    final v = (_activePct * 100).toStringAsFixed(1);
    return '$v%';
  }

  // Dot color per machine status
  Color _dotColor(Machine m) {
    if (m.status == 0) return const Color(0xFF5C6BC0); // active – blue
    if (m.status == 1) return const Color(0xFFFF9800); // fault  – orange
    return const Color(0xFF1A1A2E); // inactive – dark
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF5C3A9E)));
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: BouncingScrollPhysics(),
      children: [
        // ── Performance + Donut bubble card ────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: context.cs.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              // Top row: text left | bubble chart right
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Left: performance text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _perfLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: context.cs.onSurface,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Your Performance\nincreased this month by\n$_perfLabel',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: context.cs.onSurfaceVariant,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ── Right: overlapping bubble chart
                  _BubbleChart(
                    activePct: _activePct,
                    faultPct: _faultPct,
                    inactivePct: _inactivePct,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendDot(color: Color(0xFF5C6BC0), label: 'Active'),
                  SizedBox(width: 16),
                  _LegendDot(color: Color(0xFFFF9800), label: 'Maintenance.'),
                  SizedBox(width: 16),
                  _LegendDot(color: Color(0xFF1A1A2E), label: 'Inactive'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Live machine states ─────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live machine states',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.cs.onSurface),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/machines'),
              child: Row(
                children: [
                  Text('View all',
                      style: GoogleFonts.poppins(
                          color: Color(0xFF5C3A9E),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF5C3A9E), size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (machines.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('No machines found',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: machines.map((m) {
              return _MachineChip(machine: m, dotColor: _dotColor(m));
            }).toList(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Overlapping bubble chart  (Active 70% / Maintenance 20% / Inactive 10%)
// ─────────────────────────────────────────────────────────────────────────────
class _BubbleChart extends StatelessWidget {
  final double activePct;
  final double faultPct;
  final double inactivePct;
  const _BubbleChart({
    required this.activePct,
    required this.faultPct,
    required this.inactivePct,
  });

  String _fmt(double v) => '${(v * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    // Base size for the largest circle
    const base = 120.0;
    final activeD = base;
    final faultD = base * 0.58;
    final inactiveD = base * 0.40;

    return SizedBox(
      width: 155,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Large blue circle (Active)
          Positioned(
            left: 0,
            top: 10,
            child: _Bubble(
              diameter: activeD,
              color: Color(0xFF5C6BC0),
              label: _fmt(activePct),
              fontSize: 18,
            ),
          ),
          // ── Medium orange circle (Maintenance/Fault)
          Positioned(
            right: 0,
            top: 0,
            child: _Bubble(
              diameter: faultD,
              color: Color(0xFFFF9800),
              label: _fmt(faultPct),
              fontSize: 13,
            ),
          ),
          // ── Small dark circle (Inactive)
          Positioned(
            right: 4,
            bottom: 0,
            child: _Bubble(
              diameter: inactiveD,
              color: Color(0xFF1A1A2E),
              label: _fmt(inactivePct),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double diameter;
  final Color color;
  final String label;
  final double fontSize;
  const _Bubble({
    required this.diameter,
    required this.color,
    required this.label,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Legend dot
// ─────────────────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: context.cs.onSurfaceVariant,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Machine chip
// ─────────────────────────────────────────────────────────────────────────────
class _MachineChip extends StatelessWidget {
  final Machine machine;
  final Color dotColor;
  _MachineChip({required this.machine, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cs.outline),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 7),
          Text(
            machine.machineId,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Placeholder for unbuilt tabs
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: Color(0xFFCCCCCC)),
        SizedBox(height: 12),
        Text(label,
            style: GoogleFonts.poppins(
                color: context.cs.onSurfaceVariant, fontSize: 16)),
      ],
    );
  }
}
