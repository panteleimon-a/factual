import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/factual_header.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English (US)';

  final List<String> _languages = [
    'English (US)',
    'English (UK)',
    'Spanish',
    'French',
    'German',
    'Chinese',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Language',
                    style: GoogleFonts.roboto(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = language == _selectedLanguage;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              language,
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : const Color(0xFF929292),
                                width: 2,
                              ),
                              color: isSelected ? Colors.black : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
