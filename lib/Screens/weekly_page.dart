import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class WeeklyPage extends StatelessWidget {
  const WeeklyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),

        // week horizontal cards
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final day = ["S", "M", "T", "W", "T", "F", "S"][i];
              final date = 9 + i;
              final isToday = i == 2;
              return Container(
                width: 84,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFFFF9800) : const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(day, style: GoogleFonts.poppins(fontSize: 14, color: isToday ? Colors.black : Colors.white70)),
                    const SizedBox(height: 8),
                    Text("$date", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isToday ? Colors.black : Colors.white)),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // Weekly fault overview (line + area)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Fault Overview", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                Text("Weekly", style: GoogleFonts.poppins(color: Colors.white54)),
              ]),
              const SizedBox(height: 12),
              SizedBox(height: 160, child: LineChartPlaceholder()),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // quick stat chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _smallChip("Temperature", Colors.blue),
            _smallChip("Spare parts", Colors.orange),
            _smallChip("Downtime", Colors.purple),
          ],
        ),

        const SizedBox(height: 18),

        // small cards for each machine with a tiny sparkline
        Column(
          children: List.generate(4, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white12, child: Text('MC${i + 1}', style: GoogleFonts.poppins(color: Colors.white))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Machine MC${i + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text("Status: ${["Active", "Idle", "Maintenance", "Active"][i]}", style: GoogleFonts.poppins(color: Colors.white54)),
                      ],
                    ),
                  ),
                  SizedBox(width: 100, height: 36, child: LineChartPlaceholder(isMini: true)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _smallChip(String label, Color color) {
    return Chip(
      backgroundColor: const Color(0xFF121212),
      side: BorderSide(color: color.withOpacity(0.4)),
      label: Text(label, style: GoogleFonts.poppins(color: Colors.white)),
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