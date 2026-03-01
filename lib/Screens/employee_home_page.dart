// employee_home_page.dart
// Identical structure to ManagerHomePage but with purple banner + mechanic avatar.
// ignore_for_file: library_private_types_in_public_api

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fpms_app/core/theme/app_theme.dart';
import 'package:fpms_app/core/theme/theme_controller.dart';

import '../Services/auth_service.dart';
import '../Models/machine_model.dart';
import '../Models/failure_model.dart';
import '../Models/user_model.dart';
import 'Profile/profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
class EmployeeHomePage extends StatefulWidget {
  final String userName;
  const EmployeeHomePage({super.key, this.userName = 'Employee'});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cs.surface,
      body: SafeArea(
        child: IndexedStack(
          index: _bottomIndex,
          children: [
            _EmpMainContent(userName: widget.userName),
            const Center(
                child: _PlaceholderTab(
                    icon: Icons.shopping_bag_outlined, label: 'Jobs')),
            const Center(
                child: _PlaceholderTab(
                    icon: Icons.schedule_outlined, label: 'Schedule')),
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
      {'icon': 'assets/images/menu - wallet.png', 'label': 'Jobs'},
      {'icon': 'assets/images/circleicon.png', 'label': 'Schedule'},
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
              color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final sel = i == _bottomIndex;
          final iconPath = items[i]['icon'] as String;
          final label = items[i]['label'] as String;
          return GestureDetector(
            onTap: () => setState(() => _bottomIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sel)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: Color(0xFF5C3A9E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(children: [
                      Image.asset(iconPath,
                          width: 20, height: 20, color: Colors.white),
                      SizedBox(width: 6),
                      Text(label,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ]),
                  )
                else
                  Image.asset(iconPath,
                      width: 24,
                      height: 24,
                      color: context.cs.onSurfaceVariant),
                if (sel) ...[
                  const SizedBox(height: 3),
                  Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                          color: Color(0xFFFF9800), shape: BoxShape.circle)),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _EmpMainContent extends StatefulWidget {
  final String userName;
  const _EmpMainContent({required this.userName});
  @override
  State<_EmpMainContent> createState() => _EmpMainContentState();
}

class _EmpMainContentState extends State<_EmpMainContent> {
  int _tabIndex = 0; // 0=Overview, 1=Weekly, 2=Failures

  List<Machine> _machines = [];
  List<Failure> _failures = [];
  bool _loadingMachines = false;
  bool _loadingFailures = false;

  @override
  void initState() {
    super.initState();
    _fetchAll();
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

  @override
  Widget build(BuildContext context) {
    final isFailures = _tabIndex == 2;
    return Column(
      children: [
        _buildHeader(isFailures),
        Expanded(
          child: Container(
            color: context.cs.surface,
            child: Column(children: [
              const SizedBox(height: 18),
              _buildTabBar(),
              const SizedBox(height: 14),
              Expanded(child: _buildTabBody()),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
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
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: Row(children: [
            Icon(Icons.grid_view_rounded, color: Colors.white70, size: 22),
            Expanded(
              child: Center(
                child: Text(
                  isFailures ? 'Failure Overview' : 'Welcome Back',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const Icon(Icons.more_horiz, color: Colors.white70, size: 22),
          ]),
        ),
        if (isFailures) _buildChartCard() else _buildBannerCard(),
      ]),
    );
  }

  // ── Purple mechanic banner ──────────────────────────────────────────────────
  Widget _buildBannerCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1468), Color(0xFF4B3BAA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        // decorative circle
        Positioned(
          right: -10,
          top: -10,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cs.surface.withOpacity(0.10)),
          ),
        ),
        // mechanic avatar (left)
        Positioned(
          left: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
            child: Image.asset(
              'assets/images/Technician icon.png',
              width: 130,
              height: 150,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                width: 130,
                height: 150,
                color: Colors.transparent,
                child: const Icon(Icons.engineering_rounded,
                    color: Colors.white54, size: 70),
              ),
            ),
          ),
        ),
        // Text (right)
        Positioned(
          right: 14,
          top: 0,
          bottom: 0,
          left: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Machine\nOur Priority !',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25)),
              const SizedBox(height: 8),
              Text('start now and take better\ncare of your business',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.white70, height: 1.4)),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Failure line chart card ────────────────────────────────────────────────
  Widget _buildChartCard() {
    const monthLabels = ['JUN', 'JULY', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final monthIndices = [6, 7, 8, 9, 10, 11, 12];
    final counts = monthIndices
        .map((m) => _failures
            .where((f) => f.createdAt != null && f.createdAt!.month == m)
            .length
            .toDouble())
        .toList();
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
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Failures',
                  style: GoogleFonts.poppins(
                      color: context.cs.onSurfaceVariant, fontSize: 12)),
              Text('${_failures.isEmpty ? 23 : _failures.length}',
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.cs.onSurface)),
            ]),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: context.cs.outline),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Text('Monthly',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: context.cs.onSurfaceVariant)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down,
                    size: 14, color: context.cs.onSurfaceVariant),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
            height: 100,
            child: CustomPaint(
                painter: _LineChartPainter(data: chartData),
                size: Size.infinite)),
        SizedBox(height: 8),
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
      ]),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = ['Overview', 'Weekly', 'Failures'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = i == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: sel ? Border.all(color: context.cs.outline) : null,
                  boxShadow: sel
                      ? [
                          const BoxShadow(
                              color: Color(0x18000000),
                              blurRadius: 8,
                              offset: Offset(0, 2))
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(tabs[i],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel
                            ? Color(0xFF5C3A9E)
                            : context.cs.onSurfaceVariant,
                      )),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabBody() {
    switch (_tabIndex) {
      case 0:
        return _EmpOverviewTab(
            machines: _machines,
            failures: _failures,
            loadingMachines: _loadingMachines,
            loadingFailures: _loadingFailures);
      case 1:
        return _EmpWeeklyTab(failures: _failures, loading: _loadingFailures);
      case 2:
        return Stack(children: [
          _EmpAnalyticTab(failures: _failures, loading: _loadingFailures),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Color(0xFF5C3A9E),
              shape: CircleBorder(),
              elevation: 6,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ]);

      default:
        return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────────────────
class _EmpOverviewTab extends StatelessWidget {
  final List<Machine> machines;
  final List<Failure> failures;
  final bool loadingMachines, loadingFailures;

  const _EmpOverviewTab(
      {required this.machines,
      required this.failures,
      required this.loadingMachines,
      required this.loadingFailures});

  int get _total => machines.length;
  int get _activeCount => machines.where((m) => m.status == 0).length;
  int get _faultCount => machines.where((m) => m.status == 1).length;
  int get _inactiveCount => _total - _activeCount - _faultCount;
  double get _activePct => _total == 0 ? 0 : _activeCount / _total;
  double get _faultPct => _total == 0 ? 0 : _faultCount / _total;
  double get _inactivePct => _total == 0 ? 0 : _inactiveCount / _total;
  String get _perfLabel =>
      _total == 0 ? '0%' : '${(_activePct * 100).toStringAsFixed(1)}%';
  Color _dotColor(Machine m) {
    if (m.status == 0) return const Color(0xFF5C6BC0);
    if (m.status == 1) return const Color(0xFFFF9800);
    return const Color(0xFF1A1A2E);
  }

  int get _resolvedThisMonth {
    final now = DateTime.now();
    return failures
        .where((f) =>
            f.status.toLowerCase() == 'fixed' &&
            f.createdAt != null &&
            f.createdAt!.month == now.month &&
            f.createdAt!.year == now.year)
        .length;
  }

  List<double> get _monthlyResolved {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final month = ((now.month - 6 + i - 1) % 12) + 1;
      final year = now.year - (now.month - 6 + i <= 0 ? 1 : 0);
      return failures
          .where((f) =>
              f.status.toLowerCase() == 'fixed' &&
              f.createdAt != null &&
              f.createdAt!.month == month &&
              f.createdAt!.year == year)
          .length
          .toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingMachines)
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF5C3A9E)));
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: BouncingScrollPhysics(),
      children: [
        // Bubble chart card
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
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_perfLabel,
                          style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: context.cs.onSurface,
                              height: 1.1)),
                      SizedBox(height: 6),
                      Text(
                          'Your Performance\nincreased this month by\n$_perfLabel',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: context.cs.onSurfaceVariant,
                              height: 1.55)),
                    ]),
              ),
              const SizedBox(width: 16),
              _BubbleChart(
                  activePct: _activePct,
                  faultPct: _faultPct,
                  inactivePct: _inactivePct),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              _LegendDot(color: Color(0xFF5C6BC0), label: 'Active'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFFF9800), label: 'Maintenance.'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFF1A1A2E), label: 'Inactive'),
            ]),
          ]),
        ),
        SizedBox(height: 22),
        // Live machine states
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Live machine states',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.cs.onSurface)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/machines'),
            child: Row(children: [
              Text('View all',
                  style: GoogleFonts.poppins(
                      color: Color(0xFF5C3A9E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF5C3A9E), size: 18),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        if (machines.isEmpty)
          Text('No machines found',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13))
        else
          Wrap(
              spacing: 10,
              runSpacing: 10,
              children: machines
                  .map((m) => _MachineChip(machine: m, dotColor: _dotColor(m)))
                  .toList()),
        const SizedBox(height: 24),
        // Active sales card
        _ActiveJobsCard(
          resolvedCount: _resolvedThisMonth,
          chartData: _monthlyResolved.every((v) => v == 0)
              ? [1.0, 3.0, 2.0, 4.0, 2.5, 3.5, 2.0]
              : _monthlyResolved,
          loading: loadingFailures,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ACTIVE JOBS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveJobsCard extends StatelessWidget {
  final int resolvedCount;
  final List<double> chartData;
  final bool loading;
  const _ActiveJobsCard(
      {required this.resolvedCount,
      required this.chartData,
      required this.loading});

  @override
  Widget build(BuildContext context) {
    final displayVal = resolvedCount > 0
        ? '\$${(resolvedCount * 0.127).toStringAsFixed(1)}k'
        : '\$12.7k';
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Active sales',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: context.cs.onSurfaceVariant)),
            SizedBox(height: 2),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(displayVal,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.cs.onSurface)),
              SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Color(0xFF2ECC71).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.arrow_upward_rounded,
                      size: 10, color: Color(0xFF2ECC71)),
                  Text('1.3%',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              SizedBox(width: 4),
              Text('VS LAST YEAR',
                  style: GoogleFonts.poppins(
                      fontSize: 9, color: context.cs.onSurfaceVariant)),
            ]),
          ]),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                border: Border.all(color: context.cs.outline),
                borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Text('Monthly',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: context.cs.onSurfaceVariant)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down,
                  size: 14, color: context.cs.onSurfaceVariant),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        if (loading)
          const SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else
          SizedBox(
            height: 110,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: ['4k', '3k', '2k', '1k', '0']
                    .map((l) => Text(l,
                        style: GoogleFonts.poppins(
                            fontSize: 9, color: context.cs.onSurfaceVariant)))
                    .toList(),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: CustomPaint(
                      painter: _LineChartPainter(data: chartData),
                      size: Size.infinite)),
            ]),
          ),
        const SizedBox(height: 12),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEEKLY TAB – Calendar + fault overview dual-line chart
// ─────────────────────────────────────────────────────────────────────────────
class _EmpWeeklyTab extends StatefulWidget {
  final List<Failure> failures;
  final bool loading;
  const _EmpWeeklyTab({required this.failures, required this.loading});
  @override
  State<_EmpWeeklyTab> createState() => _EmpWeeklyTabState();
}

class _EmpWeeklyTabState extends State<_EmpWeeklyTab> {
  late DateTime _weekStart, _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _weekStart = _sundayOf(_today);
  }

  DateTime _sundayOf(DateTime d) => d.subtract(Duration(days: d.weekday % 7));
  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    const m = [
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
    return _weekStart.month == end.month
        ? '${m[_weekStart.month]} ${_weekStart.year}'
        : '${m[_weekStart.month]} – ${m[end.month]} ${end.year}';
  }

  List<double> _series(bool isCritical) {
    final d = List.generate(7, (i) {
      final day = _weekStart.add(Duration(days: i));
      return widget.failures
          .where((f) {
            if (f.createdAt == null) return false;
            final match = _same(f.createdAt!, day);
            return isCritical
                ? match && f.severityLevel.toLowerCase() == 'critical'
                : match && f.severityLevel.toLowerCase() != 'critical';
          })
          .length
          .toDouble();
    });
    return d.every((v) => v == 0)
        ? (isCritical
            ? [60.0, 95.0, 45.0, 75.0, 50.0, 30.0, 55.0]
            : [30.0, 50.0, 70.0, 45.0, 65.0, 80.0, 40.0])
        : d;
  }

  Widget _arrowBtn(IconData ic, VoidCallback fn) => GestureDetector(
        onTap: fn,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.cs.outline),
              color: context.cs.surface),
          child: Icon(ic, size: 18, color: Color(0xFF777777)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const dayL = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const dayF = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      physics: BouncingScrollPhysics(),
      children: [
        // Calendar card
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
                  offset: Offset(0, 4))
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_monthLabel(),
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.cs.onSurface)),
              Row(children: [
                _arrowBtn(
                    Icons.chevron_left,
                    () => setState(() => _weekStart =
                        _weekStart.subtract(const Duration(days: 7)))),
                const SizedBox(width: 6),
                _arrowBtn(
                    Icons.chevron_right,
                    () => setState(() =>
                        _weekStart = _weekStart.add(const Duration(days: 7)))),
              ]),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayL.asMap().entries.map((e) {
                final d = _weekStart.add(Duration(days: e.key));
                final isT = _same(d, _today);
                final isPast = d.isBefore(_today) && !isT;
                return SizedBox(
                    width: 36,
                    child: Center(
                        child: Text(e.value,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: (isT || isPast)
                                    ? Color(0xFFFF9800)
                                    : context.cs.onSurfaceVariant))));
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day = _weekStart.add(Duration(days: i));
                final isT = _same(day, _today);
                final isPast = day.isBefore(_today) &&
                    !_same(day, _today) &&
                    day.isAfter(_weekStart.subtract(const Duration(days: 1)));
                return Column(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: isT
                        ? BoxDecoration(
                            color: Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(20))
                        : null,
                    child: Center(
                        child: Text('${day.day}'.padLeft(2, '0'),
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight:
                                    isT ? FontWeight.bold : FontWeight.w400,
                                color: isT
                                    ? Colors.white
                                    : isPast
                                        ? Color(0xFFFF9800)
                                        : context.cs.onSurfaceVariant))),
                  ),
                  const SizedBox(height: 4),
                  if (isT)
                    Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFF9800), shape: BoxShape.circle)),
                ]);
              }),
            ),
          ]),
        ),
        SizedBox(height: 20),
        // Fault overview chart
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.cs.outline),
            boxShadow: [
              BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4))
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('performance Overview',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.cs.onSurface)),
              Row(children: [
                Text('Weekly',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5C3A9E))),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF5C3A9E), size: 18),
              ]),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              height: 180,
              child: widget.loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF5C3A9E), strokeWidth: 2))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: ['100', '50', '25', '0']
                                .map((l) => Text(l,
                                    style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        color: context.cs.onSurfaceVariant)))
                                .toList(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: CustomPaint(
                            painter: _DualLineChartPainter(
                              series1: _series(true),
                              series2: _series(false),
                              color1: Color(0xFF3F51B5),
                              color2: Color(0xFFFF9800),
                              tooltipLabel: '+1.7%',
                              tooltipIndex: 4, // Thu

                              todayIndex: _today.weekday % 7,
                            ),
                            size: Size.infinite,
                          )),
                        ]),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const SizedBox(width: 32),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: dayF.asMap().entries.map((e) {
                  final d = _weekStart.add(Duration(days: e.key));
                  final isT = _same(d, _today);
                  return Text(e.value,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: isT ? FontWeight.w700 : FontWeight.w400,
                        color: isT
                            ? Color(0xFF5C3A9E)
                            : context.cs.onSurfaceVariant,
                      ));
                }).toList(),
              )),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const SizedBox(width: 32),
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Color(0xFF3F51B5), shape: BoxShape.circle)),
              SizedBox(width: 5),
              Text('Temperature',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: context.cs.onSurfaceVariant)),
              SizedBox(width: 20),
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Color(0xFFFF9800), shape: BoxShape.circle)),
              SizedBox(width: 5),
              Text('spare parts',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: context.cs.onSurfaceVariant)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ANALYTIC TAB – read-only failure log
// ─────────────────────────────────────────────────────────────────────────────
class _EmpAnalyticTab extends StatefulWidget {
  final List<Failure> failures;
  final bool loading;
  const _EmpAnalyticTab({required this.failures, required this.loading});
  @override
  State<_EmpAnalyticTab> createState() => _EmpAnalyticTabState();
}

class _EmpAnalyticTabState extends State<_EmpAnalyticTab> {
  int _filterIndex = 0;

  List<Failure> get _filtered {
    if (_filterIndex == 1)
      return widget.failures
          .where((f) => f.severityLevel.toLowerCase() == 'critical')
          .toList();
    if (_filterIndex == 2)
      return widget.failures.where((f) => f.assignedTo.isNotEmpty).toList();
    return widget.failures;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading)
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF5C3A9E)));
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Text('Failure log',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.cs.onSurface)),
          Spacer(),
          _pill('All', 0),
          const SizedBox(width: 6),
          _pill('Critical', 1),
          const SizedBox(width: 6),
          _pill('Assigned', 2),
        ]),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: _filtered.isEmpty
            ? Center(
                child: Text('No failures found',
                    style:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 14)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                physics: const BouncingScrollPhysics(),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _FailureCard(
                  failure: _filtered[i],
                  onResolve: () => _showResolveDialog(context, _filtered[i]),
                ),
              ),
      ),
    ]);
  }

  void _showResolveDialog(BuildContext context, Failure failure) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => _ResolveFailureDialog(failure: failure),
    );
  }

  Widget _pill(String label, int idx) {
    final sel = _filterIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = idx),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? Color(0xFF2E2E4A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: sel ? Color(0xFF2E2E4A) : context.cs.outline),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? Colors.white : context.cs.onSurfaceVariant)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _BubbleChart extends StatelessWidget {
  final double activePct, faultPct, inactivePct;
  const _BubbleChart(
      {required this.activePct,
      required this.faultPct,
      required this.inactivePct});
  String _fmt(double v) => '${(v * 100).toStringAsFixed(0)}%';
  @override
  Widget build(BuildContext context) {
    const base = 120.0;
    return SizedBox(
        width: 155,
        height: 130,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
              left: 0,
              top: 10,
              child: _Bubble(
                  diameter: base,
                  color: Color(0xFF5C6BC0),
                  label: _fmt(activePct),
                  fontSize: 18)),
          Positioned(
              right: 0,
              top: 0,
              child: _Bubble(
                  diameter: base * 0.58,
                  color: Color(0xFFFF9800),
                  label: _fmt(faultPct),
                  fontSize: 13)),
          Positioned(
              right: 4,
              bottom: 0,
              child: _Bubble(
                  diameter: base * 0.40,
                  color: Color(0xFF1A1A2E),
                  label: _fmt(inactivePct),
                  fontSize: 11)),
        ]));
  }
}

class _Bubble extends StatelessWidget {
  final double diameter, fontSize;
  final Color color;
  final String label;
  const _Bubble(
      {required this.diameter,
      required this.color,
      required this.label,
      required this.fontSize});
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
                offset: Offset(0, 4))
          ]),
      child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700))),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: context.cs.onSurfaceVariant,
                fontWeight: FontWeight.w500)),
      ]);
}

class _MachineChip extends StatelessWidget {
  final Machine machine;
  final Color dotColor;
  _MachineChip({required this.machine, required this.dotColor});
  @override
  Widget build(BuildContext context) => Container(
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
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 9,
              height: 9,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          SizedBox(width: 7),
          Text(machine.machineId,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.cs.onSurface)),
        ]),
      );
}

class _FailureCard extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onResolve;
  const _FailureCard({required this.failure, this.onResolve});
  @override
  Widget build(BuildContext context) {
    final status = failure.status.toLowerCase();
    final severity = failure.severityLevel.toLowerCase();
    Color borderColor;
    Color badgeColor;
    String badgeLabel;
    if (status == 'fixed') {
      borderColor = const Color(0xFF2ECC71);
      badgeColor = const Color(0xFF2ECC71);
      badgeLabel = 'Fixed';
    } else if (severity == 'critical') {
      borderColor = const Color(0xFFE53935);
      badgeColor = const Color(0xFFE53935);
      badgeLabel = 'Critical';
    } else {
      borderColor = Color(0xFFFF9800);
      badgeColor = Color(0xFFFF9800);
      badgeLabel = status == 'open' ? 'Open' : _cap(status);
    }
    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(
                  '#${failure.id.length > 6 ? failure.id.substring(failure.id.length - 6).toUpperCase() : failure.id.toUpperCase()}',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.cs.onSurface))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeColor.withOpacity(0.5))),
            child: Text(badgeLabel,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: badgeColor,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        SizedBox(height: 2),
        Text(failure.machineId,
            style: GoogleFonts.poppins(
                fontSize: 11, color: context.cs.onSurfaceVariant)),
        SizedBox(height: 6),
        Text(
            failure.description.isNotEmpty
                ? failure.description
                : 'No description provided.',
            style: GoogleFonts.poppins(
                fontSize: 12, color: context.cs.onSurfaceVariant, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: 8),
        Row(children: [
          Icon(Icons.person_outline,
              size: 14, color: context.cs.onSurfaceVariant),
          SizedBox(width: 4),
          Expanded(
            child: Text(
                failure.assignedTo.isNotEmpty
                    ? failure.assignedTo.split('@').first
                    : 'Unassigned',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: context.cs.onSurfaceVariant)),
          ),
          GestureDetector(
            onTap: onResolve,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Resolve',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C3A9E))),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF5C3A9E), size: 16),
            ]),
          ),
        ]),
      ]),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
//  RESOLVE FAILURE DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class _ResolveFailureDialog extends StatefulWidget {
  final Failure failure;
  const _ResolveFailureDialog({required this.failure});
  @override
  State<_ResolveFailureDialog> createState() => _ResolveFailureDialogState();
}

class _ResolveFailureDialogState extends State<_ResolveFailureDialog> {
  // 0=Open, 1=Fixed
  int _statusIndex = 0;
  List<User> _engineers = [];
  String? _selectedEngineer;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadEngineers();
  }

  Future<void> _loadEngineers() async {
    try {
      final users = await AuthService().getTechnicians();

      if (mounted) setState(() => _engineers = users);
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final newStatus = _statusIndex == 1 ? 'fixed' : 'open';
      await AuthService().updateFailureStatus(
        failureId: widget.failure.id,
        status: newStatus,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failure marked as $newStatus',
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: Color(0xFF5C3A9E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cs.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + X
            Row(
              children: [
                Text('Resolve Failure',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: context.cs.onSurface)),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: context.cs.surfaceContainerHighest,
                        shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: context.cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Mark as
            Text('Mark as',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.cs.onSurfaceVariant)),
            SizedBox(height: 10),
            Row(children: [
              _statusPill('Open', 0, const Color(0xFFFF9800)),
              const SizedBox(width: 12),
              _statusPill('Fixed', 1, const Color(0xFF2ECC71)),
            ]),
            SizedBox(height: 22),

            // Request Engineer
            Text('Request Engineer',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.cs.onSurfaceVariant)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: context.cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cs.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEngineer,
                  isExpanded: true,
          dropdownColor: context.cs.surface,
                  hint: Text('Select engineer',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: context.cs.onSurfaceVariant)),
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: context.cs.onSurfaceVariant),
                  items: _engineers
                      .map((u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(
                                u.fullName.isNotEmpty ? u.fullName : u.email,
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: context.cs.onSurface)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedEngineer = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5C3A9E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: context.cs.surface, strokeWidth: 2))
                    : Text('Save',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String label, int idx, Color color) {
    final sel = _statusIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _statusIndex = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: sel ? 1.5 : 1.0),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                color: color)),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48, color: Color(0xFFCCCCCC)),
        SizedBox(height: 12),
        Text(label,
            style: GoogleFonts.poppins(
                color: context.cs.onSurfaceVariant, fontSize: 16)),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Line chart painter (single series)
// ─────────────────────────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce(max).clamp(1.0, double.infinity);
    final gridPaint = Paint()
      ..color = const Color(0xFFF8F8F8)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++)
      canvas.drawLine(Offset(0, size.height * i / 4),
          Offset(size.width, size.height * i / 4), gridPaint);

    final points = [
      for (int i = 0; i < data.length; i++)
        Offset(size.width * i / (data.length - 1),
            size.height * (1 - data[i] / maxVal))
    ];
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF5C6BC0).withOpacity(0.20),
              const Color(0xFF5C6BC0).withOpacity(0.02)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 =
          Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(
        linePath,
        Paint()
          ..color = const Color(0xFF5C6BC0)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    final dot = Paint()..color = const Color(0xFF5C6BC0);
    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final p in points) {
      canvas.drawCircle(p, 4, dot);
      canvas.drawCircle(p, 4, outline);
    }

    final peakIdx = data.indexOf(data.reduce(max));
    _drawTooltip(canvas, points[peakIdx], '${data[peakIdx].toInt()}');
  }

  void _drawTooltip(Canvas canvas, Offset pt, String label) {
    const tw = 52.0;
    const th = 26.0;
    const triH = 7.0;
    final left = (pt.dx - tw / 2).clamp(0.0, double.infinity);
    final top = pt.dy - th - triH - 6;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, tw, th), const Radius.circular(8)),
        Paint()..color = const Color(0xFF2E2E4A));
    canvas.drawPath(
        Path()
          ..moveTo(pt.dx - 6, top + th)
          ..lineTo(pt.dx + 6, top + th)
          ..lineTo(pt.dx, top + th + triH)
          ..close(),
        Paint()..color = Color(0xFF2E2E4A));
    final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(
        canvas, Offset(left + (tw - tp.width) / 2, top + (th - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => old.data != data;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dual-line chart painter
// ─────────────────────────────────────────────────────────────────────────────
class _DualLineChartPainter extends CustomPainter {
  final List<double> series1, series2;
  final Color color1, color2;
  final int todayIndex, tooltipIndex;
  final String tooltipLabel;

  const _DualLineChartPainter(
      {required this.series1,
      required this.series2,
      required this.color1,
      required this.color2,
      required this.tooltipLabel,
      required this.tooltipIndex,
      required this.todayIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final fixedMax = 100.0;
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;
    for (final v in [0.0, 25.0, 50.0, 100.0])
      canvas.drawLine(Offset(0, size.height * (1 - v / fixedMax)),
          Offset(size.width, size.height * (1 - v / fixedMax)), gridPaint);

    List<Offset> pts(List<double> data) => [
          for (int i = 0; i < data.length; i++)
            Offset(size.width * i / (data.length - 1),
                size.height * (1 - data[i] / fixedMax))
        ];
    final p1 = pts(series1);
    final p2 = pts(series2);

    void drawFill(List<Offset> points, Color color) {
      final fp = Path()..moveTo(points.first.dx, size.height);
      for (final p in points) fp.lineTo(p.dx, p.dy);
      fp
        ..lineTo(points.last.dx, size.height)
        ..close();
      canvas.drawPath(
          fp,
          Paint()
            ..shader = LinearGradient(
                    colors: [color.withOpacity(0.18), color.withOpacity(0.02)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)
                .createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    }

    void drawLine(List<Offset> points, Color color) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final cp1 =
            Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
        final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
        path.cubicTo(
            cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }

    drawFill(p2, const Color(0xFF26A69A));
    drawFill(p1, color1);
    drawLine(p2, color2);
    drawLine(p1, color1);

    if (tooltipIndex < p1.length) {
      final tp = p1[tooltipIndex];
      canvas.drawCircle(tp, 5, Paint()..color = color1);
      canvas.drawCircle(
          tp,
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      _drawTooltip(canvas, tp, tooltipLabel, color1);
    }
  }

  void _drawTooltip(Canvas canvas, Offset pt, String label, Color color) {
    const tw = 52.0;
    const th = 22.0;
    const r = 11.0;
    const triH = 6.0;
    final left = (pt.dx - tw / 2).clamp(0.0, double.infinity);
    final top = pt.dy - th - triH - 8;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, tw, th), const Radius.circular(r)),
        Paint()..color = color);
    canvas.drawPath(
        Path()
          ..moveTo(pt.dx - 5, top + th)
          ..lineTo(pt.dx + 5, top + th)
          ..lineTo(pt.dx, top + th + triH)
          ..close(),
        Paint()..color = color);
    final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(
        canvas, Offset(left + (tw - tp.width) / 2, top + (th - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _DualLineChartPainter old) =>
      old.series1 != series1 || old.series2 != series2;
}
