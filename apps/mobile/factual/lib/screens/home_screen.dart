import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/factual_header.dart';
import '../widgets/regional_news_carousel.dart';
import '../widgets/worldwide_news_list.dart';
import '../widgets/worldwide_news_carousel.dart';
import '../services/llm_service.dart';
import '../providers/news_provider.dart';
import '../providers/location_provider.dart';
import '../services/user_activity_service.dart';
import '../widgets/history_overlay.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _searchLayerLink = LayerLink();
  OverlayEntry? _searchOverlayEntry;
  bool _isHistoryOpen = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final List<String> _rotatingHints = [
    'Search or ask factual...',
    'Is Trump backing up Israel to bomb Iran?',
    'Global warming impact on Sweden\'s agriculture',
    'Future of AI in journalism',
    'Latest breakthroughs in fusion energy',
    'Economic situation in the European Union',
  ];
  int _hintIndex = 0;
  Timer? _hintTimer;
  late String _currentHint;

  @override
  void initState() {
    super.initState();
    _currentHint = _rotatingHints[0];
    _startHintRotation();
    // Trigger initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _initSpeech();
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
            _searchController.text = result.recognizedWords;
            // Manually trigger overlay logic since programmatic update doesn't fire onChanged
            if (_searchController.text.isNotEmpty) {
              _showSearchOverlay();
            }
          });
        },
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _loadData() async {
    print('HomeScreen: _loadData starting...');
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final locProvider = Provider.of<LocationProvider>(context, listen: false);

    // 1. Load worldwide news immediately (Critical content)
    print('HomeScreen: Loading top worldwide headlines...');
    // Don't await strictly if we want parallel, but awaiting ensures data presence for next steps. 
    // Given the issue, let's load it first.
    await newsProvider.loadTopHeadlines();
    print('HomeScreen: Worldwide articles loaded: ${newsProvider.articles.length}');

    // 2. Get location (this triggers notifyListeners in LocationProvider)
    print('HomeScreen: Calling getCurrentLocation...');
    await locProvider.getCurrentLocation();
    print('HomeScreen: Location obtained: ${locProvider.currentLocation?.countryCode}');
    
    // 3. Load regional news based on detected country
    final countryCode = locProvider.currentLocation?.countryCode?.toLowerCase();
    await newsProvider.loadRegionalHeadlines(country: countryCode);
    
    // 4. Try to load personalized feed if user has history (Requires DB, safe)
    await newsProvider.loadSmartFeed(
      'default_user', 
      location: locProvider.currentLocation?.country,
    );

    // 5. Trigger global deep analysis for trending items (Utility C) - Non-blocking UI
    if (mounted && newsProvider.articles.isNotEmpty) {
      final llmService = Provider.of<LLMService>(context, listen: false);
      newsProvider.loadGlobalContexts(llmService, count: 10); // Fire and forget
    }

    // 6. Cloud Sync / User Activity (Potential Blocker - Do last)
    try {
      if (locProvider.currentLocation != null) {
        final userActivityService = UserActivityService();
        await userActivityService.updateUserLocation(
          'default_user', 
          locProvider.currentLocation!.latitude, 
          locProvider.currentLocation!.longitude, 
          locProvider.currentLocation!.country,
        );
      }
      
      final userActivityService = UserActivityService();
      await userActivityService.syncPendingActivity('default_user');
    } catch (e) {
      print('HomeScreen: User activity sync failed: $e');
      // Non-fatal, continue
    }
  }

  void _startHintRotation() {
    _hintTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _hintIndex = (_hintIndex + 1) % _rotatingHints.length;
          _currentHint = _rotatingHints[_hintIndex];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: factualHeader(
        isHistoryPage: _isHistoryOpen, // Change icon to Back/Home based on state? User said "Home button" in history.
        // Actually, if it's an overlay, we might want the header to change.
        // Let's toggle the state.
        onHistoryTap: () {
          setState(() {
            _isHistoryOpen = !_isHistoryOpen;
          });
        },
      ),
      body: Stack(
        children: [
          // Main Content
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isHistoryOpen ? 0.0 : 1.0, 
            // We can fade it out or just keep it.
            // Requirement: "Left bar for history... ends right in the height where the menu bar is"
            // This implies it covers the content.
            child: PointerInterceptor(
              intercepting: _isHistoryOpen, // Prevent touches when history is open
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: Colors.black,
                child: CustomScrollView(
                  physics: _isHistoryOpen ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                  slivers: [
                    // ... Existing slivers ...
                    // Shortened for brevity in tool call, will rely on original content being preserved if I use smart replace?
                    // No, replace_file_content requires exact target. I must be careful.
                    // The target content below is the entire build method.
                    // I will insert the existing slivers here.
                    
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: CompositedTransformTarget(
                  link: _searchLayerLink,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: _currentHint,
                        hintStyle: GoogleFonts.roboto(
                          fontSize: 16, 
                          color: _hintIndex == 0 ? Colors.black38 : Colors.black54,
                          fontStyle: _hintIndex == 0 ? FontStyle.normal : FontStyle.italic,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 22, color: Colors.black45),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close, size: 20, color: Colors.black45),
                                onPressed: () {
                                  _searchController.clear();
                                  _hideSearchOverlay();
                                },
                              ),
                            GestureDetector(
                                onTap: () {
                                  if (_isListening) {
                                    _stopListening();
                                  } else {
                                    _startListening();
                                  }
                                },
                                child: Icon(
                                  _isListening ? Icons.stop_circle_rounded : Icons.mic_none_rounded, 
                                  size: 22, 
                                  color: _isListening ? Colors.red : Colors.black87,
                                ),
                              ),
                            const SizedBox(width: 12),
                          ],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _showSearchOverlay();
                        } else {
                          _hideSearchOverlay();
                        }
                      },
                      onSubmitted: (value) {
                        _hideSearchOverlay();
                        if (value.trim().isNotEmpty) {
                          // Log search query for Firebase sync
                          UserActivityService().trackSearchQuery('default_user', value.trim());
                          // Navigate to analysis
                          context.push('/query-analysis', extra: value.trim());
                        }
                      },
                      onTap: () {
                        // Keep open history toggle if requested, but now it's a real input
                      },
                    ),
                  ),
                ),
              ),
            ),
  
            // Regional Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/regional-news'),
                            behavior: HitTestBehavior.opaque, 
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0), 
                              child: Text(
                                'Top in your region',
                                style: GoogleFonts.robotoCondensed(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/map'),
                            icon: const Icon(Icons.map_outlined, size: 28),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
  
            // Regional Carousel
            const SliverToBoxAdapter(
              child: RegionalNewsCarousel(),
            ),
  
            // Worldwide Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Consumer<LocationProvider>(
                  builder: (context, locProvider, _) => GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => context.push('/worldwide-deep'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Provider.of<NewsProvider>(context, listen: false).usePersonalizedFeed ? 'Top for you' : 'Top worldwide',
                          style: GoogleFonts.roboto(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
  
            // Deep Analysis Carousel Section (Utility C)
            const SliverToBoxAdapter(
              child: WorldwideNewsCarousel(),
            ),

            // Worldwide List Section
            const SliverToBoxAdapter(
              child: WorldwideNewsList(),
            ),
  
            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
                  ],
                ),
              ),
            ),
          ),
          
          // History Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isHistoryOpen ? 0 : -MediaQuery.of(context).size.width,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width, // Pull to full width or match Figma 700? Mobile = Full width usually.
            child: const HistoryOverlay(),
          ),
        ],
      ),
    );
  }

  void _showSearchOverlay() {
    _hideSearchOverlay();
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    
    // Filter from combined articles
    final filteredArticles = newsProvider.articles.where((a) => 
      a.title.toLowerCase().contains(query) || 
      a.summary.toLowerCase().contains(query)
    ).take(5).toList();

    if (filteredArticles.isEmpty) return;

    _searchOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _searchLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemCount: filteredArticles.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return ListTile(
                  title: Text(
                    article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    article.source.name,
                    style: GoogleFonts.roboto(fontSize: 12, color: Colors.black45),
                  ),
                  onTap: () {
                    _hideSearchController();
                    context.push('/query-analysis', extra: article.title);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_searchOverlayEntry!);
  }

  void _hideSearchOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  void _hideSearchController() {
    _searchController.clear();
    _hideSearchOverlay();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hintTimer?.cancel();
    _hideSearchOverlay();
    super.dispose();
  }
}

// Helper to prevent touches
class PointerInterceptor extends StatelessWidget {
  final bool intercepting;
  final Widget child;
  const PointerInterceptor({super.key, required this.intercepting, required this.child});
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(absorbing: intercepting, child: child);
  }
}
