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
  late final List<Animation<Offset>> _letterAnimations;
  
  final List<String> _letters = ['F', 'a', 'c', 't', 'u', 'a', 'l'];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create staggered animations for each letter
    // Letters start from different horizontal positions and converge to center
    _letterAnimations = List.generate(_letters.length, (index) {
      final startOffset = (index - 3.5) * 0.3; // Spread letters horizontally
      
      return Tween<Offset>(
        begin: Offset(startOffset, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.0,
            0.8,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Start animation
    _controller.forward();
    
    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2000), () {
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
                return Transform.translate(
                  offset: _letterAnimations[index].value * 100,
                  child: Text(
                    _letters[index],
                    style: GoogleFonts.ubuntu(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
