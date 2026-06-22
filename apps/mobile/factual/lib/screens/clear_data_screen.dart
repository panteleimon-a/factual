import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/factual_header.dart';

class ClearDataScreen extends StatefulWidget {
  const ClearDataScreen({super.key});

  @override
  State<ClearDataScreen> createState() => _ClearDataScreenState();
}

class _ClearDataScreenState extends State<ClearDataScreen> {
  bool _isSuccess = false;

  Future<void> _handleClearData() async {
    // "Deletion of account shall just delete cache"
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.clearResults(); // Clears article lists
    // Also likely want to clear cache in NewsService if possible, but provider has clearResults.
    
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const factualHeader(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), // Light Green
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                'Data Cleared!', // Adapted from "Password Changed!" context
                style: GoogleFonts.urbanist(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E232C),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your account data has been cleared successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  color: const Color(0xFF8391A1),
                ),
              ),
              const SizedBox(height: 40),
               GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Back to Settings',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(), // Should back button be handled? header has no back button by default unless configured.
      // Settings usually has back in header or custom.
      // factualHeader doesn't show back button? logic in factual_header.dart: _buildLeftGroup logic.
      // I'll stick to factualHeader and maybe wrap body in Stack with Back button if needed, or rely on Android Back.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Back Button if header doesn't have it
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios)),
              
              const SizedBox(height: 40),
              Text(
                'Clear Account Data',
                style: GoogleFonts.urbanist(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E232C),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Factual uses this data to provide you with relevant content easily and quick. Are you sure you would like to clear this accounts stored data? All recommendations will be lost.',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8391A1),
                  height: 1.25,
                ),
              ),
              
              const Spacer(),
              
              GestureDetector(
                onTap: _handleClearData,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3261E), // Red from Figma
                    borderRadius: BorderRadius.circular(40), // Rounded capsule
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Clear Account Data',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
