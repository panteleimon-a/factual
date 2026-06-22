import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../widgets/factual_header.dart';
import '../widgets/voice_waveform.dart';
import '../widgets/history_sidebar.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import '../services/user_activity_service.dart';
import '../models/search_query.dart';

class ChatHubScreen extends StatefulWidget {
  final String? initialQuery;

  const ChatHubScreen({super.key, this.initialQuery});

  @override
  State<ChatHubScreen> createState() => _ChatHubScreenState();
}

class _ChatHubScreenState extends State<ChatHubScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SearchQuery> _history = [];
  bool _isLoadingHistory = true;

  // Analysis State
  String? _activeQuery;
  Map<String, dynamic>? _analysisResult;
  bool _isAnalyzing = false;

  // STT State
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Resizable sidebar state
  double _sidebarWidth = 240.0;
  static const double _minSidebarWidth = 150.0;
  static const double _maxSidebarWidth = 450.0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.initialQuery != null) {
      _performAnalysis(widget.initialQuery!);
    }
  }

  Future<void> _loadHistory() async {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final history = await db.getRecentSearches(limit: 50);
    // Sort: Pinned first, then by date descending
    history.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });

    if (mounted) {
      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _performAnalysis(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _activeQuery = query;
      _isAnalyzing = true;
      _analysisResult = null;
    });

    final db = Provider.of<DatabaseService>(context, listen: false);
    final llm = Provider.of<LLMService>(context, listen: false);
    final userActivity = UserActivityService();

    try {
      // 1. Track activity
      await userActivity.trackSearchQuery('default_user', query);

      debugPrint('🔍 ChatHubScreen: Starting analysis for query: $query');
      
      // 2. Analyze
      final analysis = await llm.processQuery(query);
      
      debugPrint('📥 ChatHubScreen: Received analysis result: $analysis');
      debugPrint('   - verdict: ${analysis['verdict']}');
      debugPrint('   - answer: ${analysis['answer']}');
      debugPrint('   - certainty: ${analysis['certainty']}');
      
      final newQuery = SearchQuery(
        id: const Uuid().v4(),
        userId: 'default_user',
        query: query,
        sentiment: 'neutral', // Utility B doesn't return sentiment, defaulting to neutral
        timestamp: DateTime.now(),
        resultJson: json.encode(analysis), // Cache the result
      );

      // 3. Save to DB
      await db.insertSearchQuery(newQuery);
      await _loadHistory();

      debugPrint('✅ ChatHubScreen: Setting analysis result in state');
      
      if (mounted) {
        setState(() {
          _analysisResult = analysis;
          _isAnalyzing = false;
        });
        debugPrint('🎨 ChatHubScreen: State updated, _analysisResult is now: $_analysisResult');
      }
    } catch (e) {
      debugPrint('❌ ChatHubScreen: Analysis failed with error: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = {
            'answer': 'Error analyzing query: $e',
            'verdict': 'Error',
            'suggestedTopics': [],
          };
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    }
  }

  // Load existing query results instead of re-analyzing
  Future<void> _loadQueryResults(SearchQuery query) async {
    setState(() {
      _activeQuery = query.query;
      _isAnalyzing = false;
      
      if (query.resultJson != null && query.resultJson!.isNotEmpty) {
        try {
          _analysisResult = json.decode(query.resultJson!) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Error decoding cached result: $e');
          _analysisResult = _fallbackResult(query);
        }
      } else {
        _analysisResult = _fallbackResult(query);
      }
    });
  }

  Map<String, dynamic> _fallbackResult(SearchQuery query) {
    return {
      'enhancedQuery': 'Analysis for: ${query.query}',
      'sentiment': query.sentiment,
      'timestamp': query.timestamp.toString(),
      'suggestedTopics': ['Search Context', 'Source Reliability', 'Fact Check'], 
    };
  }

  void _startNewChat() {
    setState(() {
      _activeQuery = null;
      _analysisResult = null;
      _controller.clear();
    });
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (errorNotification) => debugPrint('Speech error: $errorNotification'),
    );
    if (!available) {
      debugPrint('Speech recognition not available');
    }
  }

  void _startListening() async {
    var status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }
    if (!status.isGranted) return;

    if (!_speech.isAvailable) {
      await _initSpeech();
    }

    if (_speech.isAvailable) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // In unified view, the header is always present in analyzing or new chat state
                const factualHeader(),
                Expanded(
                  child: _activeQuery == null ? _buildNewChatView() : _buildAnalysisView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Row(
      children: [
        HistorySidebar(
          history: _history,
          activeQuery: _activeQuery,
          width: _sidebarWidth,
          onQueryTap: _loadQueryResults,
          onNewChatTap: _startNewChat,
          onHistoryUpdated: _loadHistory,
          showHomeButton: true,
          onHomeTap: () => context.go('/'),
        ),
        // Drag handle
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(
                _minSidebarWidth,
                _maxSidebarWidth,
              );
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: 8,
              color: const Color(0xFFF9F9F9),
              child: Center(
                child: Container(
                  width: 2,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewChatView() {
    return Column(
      children: [
        // factualHeader already in build()
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _controller,
                          maxLines: 3,
                          style: GoogleFonts.roboto(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Type here...',
                            hintStyle: GoogleFonts.roboto(color: Colors.black26),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _performAnalysis,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () => _performAnalysis(_controller.text),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(
                                    'Enter',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                               onTap: () {
                                 if (_isListening) {
                                   _stopListening();
                                 } else {
                                   _startListening();
                                 }
                               },
                               child: Icon(
                                 _isListening ? Icons.stop_circle_rounded : Icons.mic_none_outlined, 
                                 color: _isListening ? Colors.red : Colors.black54, 
                                 size: 28,
                               ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isListening) ...[
                    const SizedBox(height: 48),
                    const VoiceWaveform(),
                    const SizedBox(height: 16),
                    Text(
                      'Listening...',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisView() {
    if (_isAnalyzing) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (_analysisResult == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // 1. Verdict & Certainty Header
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text(
                (_analysisResult!['verdict'] ?? 'UNKNOWN').toString().toUpperCase(),
                style: GoogleFonts.robotoCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'CERTAINTY: ${(_analysisResult!['certainty'] ?? 'N/A').toString().toUpperCase()}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Main Answer
          Text(
            _analysisResult!['answer'] ?? 'No answer available.',
            style: GoogleFonts.roboto(
              fontSize: 20,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),

          // 3. Controversy (If any)
          if (_analysisResult!['controversy'] != null && 
              _analysisResult!['controversy'] != 'None') ...[
            Text(
              'CONTROVERSY & DISAGREEMENT',
              style: GoogleFonts.robotoCondensed(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.black26,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFEAEA)),
              ),
              child: Text(
                _analysisResult!['controversy'].toString(),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],

          // 4. Sources
          if (_analysisResult!['sources'] != null) ...[
            Text(
              'SOURCES',
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
              children: (_analysisResult!['sources'] as List).map((source) {
                return Chip(
                  avatar: const Icon(Icons.check_circle, size: 16, color: Colors.black54),
                  label: Text(source.toString()),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFEEEEEE)),
                  labelStyle: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
          ],

          // 5. Suggested Topics
          if (_analysisResult!['suggestedTopics'] != null) ...[
            _buildSuggestedExploration(),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestedExploration() {
    final topics = _analysisResult!['suggestedTopics'] as List?;
    if (topics == null || topics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: topics.map((topic) {
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
    );
  }
}
