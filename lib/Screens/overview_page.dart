import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OverviewPage extends StatelessWidget {
  final bool isDarkMode;
  const OverviewPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final textColorLight = isDarkMode ? Colors.white60 : Colors.black54;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),
        // small row for overview + donut & stats
        Row(
          children: [
            // left: text & percent
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("5.7%",
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 6),
                  Text("Your Performance increased this month by 5.7%",
                      style: GoogleFonts.poppins(color: textColorLight)),
                  const SizedBox(height: 12),
                  // Use Wrap to avoid horizontal overflow on narrow screens
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _legendDot("Active", Colors.blue),
                      _legendDot("Maintenance", Colors.orange),
                      _legendDot("Inactive", Colors.grey),
                    ],
                  ),
                ],
              ),
            ),

            // right: donut placeholder
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 120,
                child: Center(
                    child: SizedBox(
                        width: 120,
                        height: 120,
                        child: CustomPaint(painter: DonutPainter()))),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        // Header + button to view all machines
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Live Machine States',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/machines'),
              icon: Icon(Icons.list_alt, size: 18, color: textColor),
              label: Text('View All', style: TextStyle(color: textColor)),
              style: TextButton.styleFrom(foregroundColor: textColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Live machine states chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(8, (i) {
            return Chip(
              backgroundColor:
                  isDarkMode ? const Color(0xFF121212) : Colors.grey[200],
              side: BorderSide(
                  color: isDarkMode ? Colors.white10 : Colors.grey[400]!),
              label: Text('MC${i + 1}',
                  style: GoogleFonts.poppins(color: textColor)),
            );
          }),
        ),

        // Large card: active sales placeholder chart

        const SizedBox(height: 18),

        // bottom summary cards row
        Row(
          children: [
            Expanded(child: _smallStatCard("Total Machines", "28")),
            const SizedBox(width: 12),
            Expanded(child: _smallStatCard("Active", "15")),
            const SizedBox(width: 12),
            Expanded(child: _smallStatCard("Under Maintenance", "3")),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _smallStatCard(String title, String value) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final textColorLight = isDarkMode ? Colors.white54 : Colors.black54;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(color: textColorLight, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    final textColorLight = isDarkMode ? Colors.white70 : Colors.black54;
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(color: textColorLight)),
      ],
    );
  }
}

BoxDecoration _cardDecoration(bool isDarkMode) {
  return BoxDecoration(
    color: isDarkMode ? const Color(0xFF121212) : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey[300]!),
    boxShadow: [
      BoxShadow(
          color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4))
    ],
  );
}

/// Donut placeholder painter (three segments)
class DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = min(size.width, size.height) / 2;
    final stroke = radius * 0.28;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // draw segments
    final angles = [0.7, 0.25, 0.35]; // proportions
    final colors = [Colors.blue, Colors.orange, Colors.grey];
    double start = -pi / 2;
    for (int i = 0; i < angles.length; i++) {
      paint.color = colors[i];
      final sweep = angles[i] / (angles.reduce((a, b) => a + b)) * 2 * pi;
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - stroke / 2),
          start,
          sweep,
          false,
          paint);
      start += sweep;
    }

    // inner circle to create donut hole (use theme-aware color if needed in future)
    final innerPaint = Paint()..color = const Color(0xFF0D0D0D);
    canvas.drawCircle(center, radius - stroke - 6, innerPaint);

    // small percentage text (center)
    final tp = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.text = TextSpan(
        text: '70%',
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple line chart placeholder
class LineChartPlaceholder extends StatelessWidget {
  final bool isMini;
  const LineChartPlaceholder({this.isMini = false, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(),
      child: Container(),
    );
  }
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    final gapY = size.height / 4;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
          Offset(0, i * gapY), Offset(size.width, i * gapY), paintGrid);
    }

    final paint = Paint()
      ..color = const Color(0xFF6EC6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final rng = Random(42);
    for (int i = 0; i <= 12; i++) {
      final x = size.width * (i / 12);
      final y = size.height / 2 +
          sin(i / 12 * 2 * pi) *
              (size.height / 3) *
              (0.6 + rng.nextDouble() * 0.6);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // small dots
    final dot = Paint()..color = const Color(0xFFFF9800);
    for (int i = 0; i <= 12; i += 3) {
      final x = size.width * (i / 12);
      final y =
          size.height / 2 + sin(i / 12 * 2 * pi) * (size.height / 3) * 0.9;
      canvas.drawCircle(Offset(x, y), 3.8, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bar chart placeholder
class BarChartPlaceholder extends StatelessWidget {
  const BarChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarPainter(),
      child: Container(),
    );
  }
}

class _BarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(123);
    final barPaint = Paint()..style = PaintingStyle.fill;
    final count = 7;
    final spacing = size.width / (count * 2 + 1);
    for (int i = 0; i < count; i++) {
      final x = spacing + i * spacing * 2;
      final h = (size.height * 0.2) + rng.nextDouble() * (size.height * 0.75);
      barPaint.color = i == 6 ? const Color(0xFFFF9800) : Colors.white24;
      final rect = Rect.fromLTWH(x - spacing / 2, size.height - h, spacing, h);
      final r = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(r, barPaint);
    }

    // baseline
    final base = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), base);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
