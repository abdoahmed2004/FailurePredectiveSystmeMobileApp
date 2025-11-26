import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),
        // top stat cards
        Row(
          children: [
            Expanded(child: _analyticStatCard("Total Machines", "28")),
            const SizedBox(width: 12),
            Expanded(child: _analyticStatCard("Active", "15")),
            const SizedBox(width: 12),
            Expanded(child: _analyticStatCard("Under Maintenance", "3")),
          ],
        ),

        const SizedBox(height: 18),

        // Table placeholder
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Machines", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                children: List.generate(4, (i) {
                  final priority = i.isEven ? "High" : (i == 1 ? "Medium" : "Low");
                  return TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("MC${i + 1}", style: GoogleFonts.poppins()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Reported: ${["Mar 21", "Mar 30", "Aug 12", "Oct 3"][i]}", style: GoogleFonts.poppins(color: Colors.white54)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: priority == "High" ? Colors.redAccent.withOpacity(0.15) : (priority == "Medium" ? Colors.orange.withOpacity(0.12) : Colors.green.withOpacity(0.12)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(priority, style: GoogleFonts.poppins(color: priority == "High" ? Colors.redAccent : (priority == "Medium" ? Colors.orange : Colors.green))),
                        ),
                      ),
                    ),
                  ]);
                }),
              )
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Bar chart placeholder
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total performance", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(height: 160, child: BarChartPlaceholder()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _analyticStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.white54)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: const Color(0xFF121212),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white10),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
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
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - stroke / 2), start, sweep, false, paint);
      start += sweep;
    }

    // inner circle to create donut hole
    final innerPaint = Paint()..color = const Color(0xFF0D0D0D);
    canvas.drawCircle(center, radius - stroke - 6, innerPaint);

    // small percentage text (center)
    final tp = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.text = TextSpan(text: '70%', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
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
    final paintGrid = Paint()..color = Colors.white12..strokeWidth = 1;
    final gapY = size.height / 4;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(Offset(0, i * gapY), Offset(size.width, i * gapY), paintGrid);
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
      final y = size.height / 2 + sin(i / 12 * 2 * pi) * (size.height / 3) * (0.6 + rng.nextDouble() * 0.6);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // small dots
    final dot = Paint()..color = const Color(0xFFFF9800);
    for (int i = 0; i <= 12; i += 3) {
      final x = size.width * (i / 12);
      final y = size.height / 2 + sin(i / 12 * 2 * pi) * (size.height / 3) * 0.9;
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
    final base = Paint()..color = Colors.white12..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), base);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}