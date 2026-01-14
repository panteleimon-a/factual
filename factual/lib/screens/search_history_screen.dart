import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/factual_header.dart';
import '../widgets/voice_waveform.dart';
import '../providers/news_provider.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import '../models/search_query.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SearchQuery> _history = [];
  bool _isLoading = true;

  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final history = await db.getRecentSearches(limit: 20);
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final db = Provider.of<DatabaseService>(context, listen: false);
    final llm = Provider.of<LLMService>(context, listen: false);
    
    String sentiment = 'neutral';
    try {
      final analysis = await llm.analyzeSentiment(query);
      sentiment = analysis['sentiment'] ?? 'neutral';
    } catch (e) {
      print('Query sentiment analysis failed: $e');
    }

    final newQuery = SearchQuery(
      id: const Uuid().v4(),
      userId: 'default_user', 
      query: query,
      sentiment: sentiment,
      timestamp: DateTime.now(),
    );
    
    await db.insertSearchQuery(newQuery);
    if (mounted) {
      context.push('/search', extra: query);
    }
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      // Start listening
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('STT Status: $status');
          if (status == 'notListening' && _isListening) {
             // Logic to handle auto-stop if silence, or keep it open?
             // For now we just sync the state
             setState(() => _isListening = false);
             if (_controller.text.isNotEmpty) {
               _handleSearch(_controller.text);
             }
          }
        },
        onError: (errorNotification) {
          print('STT Error: $errorNotification');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            });
          },
        );
      } else {
        // Permission denied or not available
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Microphone permission required for voice search')),
            );
          }
        }
      }
    } else {
      // Stop listening
      setState(() => _isListening = false);
      _speech.stop();
      if (_controller.text.isNotEmpty) {
        _handleSearch(_controller.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // History List
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    children: [
                      Text(
                        'Recent chat history',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black26,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_history.isEmpty)
                        Text(
                          'No previous searches found.',
                          style: GoogleFonts.roboto(color: Colors.black26),
                        )
                      else
                        ..._history.map((q) => _buildHistoryItem(q)),
                    ],
                  ),
            ),

            // Large Prompt Input Area (Chat Style)
            Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.white : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: _isListening ? Colors.black : const Color(0xFFE0E0E0), 
                    width: _isListening ? 2 : 1
                  ),
                  boxShadow: _isListening ? [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                  ] : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isListening) ...[
                      VoiceWaveform(isActive: true),
                      const SizedBox(height: 16),
                      Text(
                        'Listening...',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                      ),
                    ] else
                      TextField(
                        controller: _controller,
                        maxLines: 4,
                        style: GoogleFonts.roboto(fontSize: 18, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Ask anything...',
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.black38,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _handleSearch,
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _handleSearch(_controller.text),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'Enter',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _toggleListening,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isListening ? Colors.black : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isListening ? Icons.stop_rounded : Icons.mic_none_rounded, 
                              size: 28, 
                              color: _isListening ? Colors.white : Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(SearchQuery query) {
    Color sentimentColor = Colors.black26;
    IconData sentimentIcon = Icons.chat_bubble_outline;
    
    if (query.sentiment == 'positive') {
      sentimentColor = Colors.green.shade300;
      sentimentIcon = Icons.sentiment_satisfied_rounded;
    } else if (query.sentiment == 'negative') {
      sentimentColor = Colors.red.shade300;
      sentimentIcon = Icons.sentiment_very_dissatisfied_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => context.push('/search', extra: query.query),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF5F5F5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(sentimentIcon, size: 18, color: sentimentColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      query.query,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(query.timestamp),
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        color: Colors.black26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
