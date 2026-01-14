import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/news_provider.dart';
import '../providers/location_provider.dart';
import '../models/news_article.dart';

class RegionalNewsCarousel extends StatefulWidget {
  const RegionalNewsCarousel({super.key});

  @override
  State<RegionalNewsCarousel> createState() => _RegionalNewsCarouselState();
}

class _RegionalNewsCarouselState extends State<RegionalNewsCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewsProvider, LocationProvider>(
      builder: (context, newsProvider, locProvider, child) {
        final isLoading = newsProvider.isRegionalLoading || locProvider.isLoading;
        
        if (isLoading) {
          return _buildSkeletonLoader();
        }

        final articles = newsProvider.regionalArticles;

        if (articles.isEmpty) {
          return _buildEmptyState();
        }

        return SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(articles[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(NewsArticle article, int index) {
    // Dynamic Transition Logic: Scale and Rotation based on page offset
    double relativePosition = index - _currentPage;
    double scale = (1 - (relativePosition.abs() * 0.15)).clamp(0.85, 1.0);
    double opacity = (1 - (relativePosition.abs() * 0.5)).clamp(0.5, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTap: () => context.push('/article-detail', extra: article),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    flex: 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (article.imageUrl != null)
                          Image.network(
                            article.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        else
                          _buildPlaceholder(),
                        
                        // Gradient Overlay for readability
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Category/Source Badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              article.source.name.toUpperCase(),
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 14, color: Colors.black38),
                              const SizedBox(width: 6),
                              Text(
                                '${DateTime.now().difference(article.publishedAt).inHours}h ago',
                                style: GoogleFonts.roboto(fontSize: 12, color: Colors.black38),
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
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SizedBox(
      height: 260,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.white,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: Colors.black12),
            const SizedBox(height: 12),
            Text(
              'No regional news available',
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.black12),
      ),
    );
  }
}
