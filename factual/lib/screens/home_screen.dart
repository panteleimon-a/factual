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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final locProvider = Provider.of<LocationProvider>(context, listen: false);

    // 1. Get location (this triggers notifyListeners in LocationProvider)
    await locProvider.getCurrentLocation();
    
    // 2. Load regional news based on detected country
    final countryCode = locProvider.currentLocation?.countryCode?.toLowerCase() ?? 'us';
    await newsProvider.loadRegionalHeadlines(country: countryCode);
    
    // 3. Load smart feed (Top Worldwide or Personalized if history exists)
    await newsProvider.loadSmartFeed('default_user');

    // 4. Trigger global deep analysis for trending items (Utility C)
    if (mounted) {
      final llmService = Provider.of<LLMService>(context, listen: false);
      await newsProvider.loadGlobalContexts(llmService, count: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.black,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: GestureDetector(
                  onTap: () => context.push('/search-history'),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        const Icon(Icons.search_rounded, size: 22, color: Colors.black45),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search or ask factual...',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                        const Icon(Icons.mic_none_rounded, size: 22, color: Colors.black87),
                        const SizedBox(width: 12),
                      ],
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
                    GestureDetector(
                      onTap: () => context.push('/map'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top in your region',
                            style: GoogleFonts.roboto(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Icon(Icons.map_outlined, size: 28),
                        ],
                      ),
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
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
                child: Consumer<NewsProvider>(
                  builder: (context, provider, _) => GestureDetector(
                    onTap: () => context.push('/worldwide-deep'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.usePersonalizedFeed ? 'Top for you' : 'Top worldwide',
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
    );
  }
}
