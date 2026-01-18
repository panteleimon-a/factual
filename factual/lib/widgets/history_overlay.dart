import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import 'voice_waveform.dart';
import 'history_sidebar.dart';
import '../services/database_service.dart';
import '../models/search_query.dart';

class HistoryOverlay extends StatefulWidget {
  const HistoryOverlay({super.key});

  @override
  State<HistoryOverlay> createState() => _HistoryOverlayState();
}

class _HistoryOverlayState extends State<HistoryOverlay> {
  final TextEditingController _controller = TextEditingController();
  List<SearchQuery> _history = [];
  bool _isLoading = true;
  bool _isListening = false;
  String? _activeQuery;
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Resizable sidebar state
  double _sidebarWidth = 240.0;
  static const double _minSidebarWidth = 150.0;
  static const double _maxSidebarWidth = 450.0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
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
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    final db = Provider.of<DatabaseService>(context, listen: false);
    final newQuery = SearchQuery(
      id: const Uuid().v4(),
      userId: 'default_user', 
      query: query,
      sentiment: 'neutral',
      timestamp: DateTime.now(),
    );
    await db.insertSearchQuery(newQuery);
    if (mounted) context.push('/query-analysis', extra: query);
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
  Widget build(BuildContext context) {
    // Mobile usually stays fixed or handled by layout, but we'll enable resizing for both
    // if width is enough.

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Left Sidebar (History List)
          HistorySidebar(
            history: _history,
            activeQuery: _activeQuery,
            width: _sidebarWidth,
            onQueryTap: (query) {
              setState(() {
                _activeQuery = query.query;
                _controller.text = query.query;
              });
            },
            onNewChatTap: () {
              _controller.clear();
              setState(() {
                _activeQuery = null;
              });
            },
            onHistoryUpdated: _loadHistory,
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
          
          // Main Content (Input Area)
          Expanded(
            child: Stack(
              children: [
                 // Center the input box
                 Center(
                   child: _buildInputArea(),
                 ),
                 if (_isListening)
                   Positioned(
                     bottom: 160,
                     left: 0,
                     right: 0,
                     child: Center(
                       child: Column(
                         children: [
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
                       ),
                     ),
                   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 122, 
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), 
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
             Expanded(
               child: TextField(
                controller: _controller,
                maxLines: null,
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type here...',
                  hintStyle: TextStyle(color: Colors.black26),
                ),
                onSubmitted: _handleSearch,
               ),
             ),
             Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 GestureDetector(
                  onTap: () => _handleSearch(_controller.text),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Enter',
                      style: GoogleFonts.roboto(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
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
                     size: 28
                   ),
                 ),
               ],
             ),
          ],
        ),
      ),
    );
  }
}
