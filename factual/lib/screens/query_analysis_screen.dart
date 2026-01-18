import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/llm_service.dart';
import '../widgets/factual_header.dart';

class QueryAnalysisScreen extends StatefulWidget {
  final String query;

  const QueryAnalysisScreen({super.key, required this.query});

  @override
  State<QueryAnalysisScreen> createState() => _QueryAnalysisScreenState();
}

class _QueryAnalysisScreenState extends State<QueryAnalysisScreen> {
  Map<String, dynamic>? _result;
  String? _analysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    setState(() => _isLoading = true);
    try {
      final llm = Provider.of<LLMService>(context, listen: false);
      // Using Utility 1 for query analysis
      final result = await llm.processQuery(widget.query);
      setState(() {
        _result = result;
        _analysis = result['enhancedQuery'] ?? 'No analysis available.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _analysis = 'Failed to analyze: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: Row(
        children: [
          // Sidebar (Mock for now, matching Figma)
          _buildSidebar(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyzed: ${widget.query}',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator(color: Colors.black)),
                    )
                  else ...[
                    if (_result != null && _result!['intent'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Text(
                          _result!['intent'].toString().toUpperCase(),
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.black26,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    Text(
                      _analysis!,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        color: Colors.black87,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (_result != null && _result!['suggestedTopics'] != null) ...[
                      Text(
                        'SUGGESTED EXPLORATION',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black26,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (_result!['suggestedTopics'] as List).map((topic) {
                          return ActionChip(
                            label: Text(topic.toString()),
                            labelStyle: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            backgroundColor: const Color(0xFFF5F5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
                            ),
                            onPressed: () => context.push('/search', extra: topic.toString()),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 130,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        border: Border(right: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildSidebarItem(Icons.history_rounded, 'History'),
          _buildSidebarItem(Icons.bookmark_outline_rounded, 'Pinned'),
          const Divider(height: 40, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'NEW CHAT',
              style: GoogleFonts.robotoCondensed(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black26,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSidebarItem(Icons.add_rounded, 'Start focus'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black45),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.robotoCondensed(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
