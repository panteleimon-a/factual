import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BiasGauge extends StatelessWidget {
  final String biasType; // "Left", "Right", "Center/Neutral", etc.
  
  const BiasGauge({super.key, required this.biasType});

  @override
  Widget build(BuildContext context) {
    double alignment = 0.0;
    Color color = Colors.grey;
    String label = "Neutral";

    if (biasType.toLowerCase().contains("left")) {
      alignment = -1.0;
      color = Colors.blueAccent;
      label = "Left Lean";
    } else if (biasType.toLowerCase().contains("right")) {
      alignment = 1.0;
      color = Colors.redAccent;
      label = "Right Lean";
    } else {
      alignment = 0.0;
      color = Colors.purpleAccent;
      label = "Center";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LEFT', style: GoogleFonts.robotoCondensed(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
            Text('CENTER', style: GoogleFonts.robotoCondensed(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
            Text('RIGHT', style: GoogleFonts.robotoCondensed(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Pointer
              AnimatedAlign(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                alignment: Alignment(alignment, 0),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.robotoCondensed(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
