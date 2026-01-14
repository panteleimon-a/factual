import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _animations;
  late final List<Offset> _startOffsets;
  
  final String _text = 'factual';
  final List<String> _letters = 'factual'.split('');

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    final random = Random();
    
    // Generate random starting points for each letter outside the screen
    _startOffsets = List.generate(_letters.length, (index) {
      double x = (random.nextDouble() * 2 - 1) * 400; // -400 to 400
      double y = (random.nextDouble() * 2 - 1) * 400; // -400 to 400
      
      // Ensure they don't start too close to center
      if (x.abs() < 100) x += (x >= 0 ? 200 : -200);
      if (y.abs() < 100) y += (y >= 0 ? 200 : -200);
      
      return Offset(x, y);
    });

    _animations = List.generate(_letters.length, (index) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (index * 0.05).clamp(0.0, 0.5),
          (index * 0.05 + 0.5).clamp(0.0, 1.0),
          curve: Curves.elasticOut,
        ),
      );
    });

    // Start animation
    _controller.forward();
    
    // Navigate after animation completes + extra beat
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_letters.length, (index) {
                final progress = _animations[index].value;
                final offset = Offset(
                  _startOffsets[index].dx * (1 - progress),
                  _startOffsets[index].dy * (1 - progress),
                );

                return Opacity(
                  opacity: progress.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: offset,
                    child: Transform.scale(
                      scale: 0.5 + (0.5 * progress),
                      child: Text(
                        _letters[index].toLowerCase(),
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 64,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
