import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';

import 'deep_analysis_card.dart';
import 'package:shimmer/shimmer.dart';

class WorldwideNewsCarousel extends StatefulWidget {
  const WorldwideNewsCarousel({super.key});

  @override
  State<WorldwideNewsCarousel> createState() => _WorldwideNewsCarouselState();
}

class _WorldwideNewsCarouselState extends State<WorldwideNewsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, _) {
        print('WorldwideNewsCarousel: Total articles = ${newsProvider.articles.length}');
        final articles = newsProvider.articles.take(3).toList();
        print('WorldwideNewsCarousel: Displaying ${articles.length} articles');
        
        // Show skeleton loading if empty or explicitly loading
        // Show skeleton loading ONLY if we have no data yet
        if (newsProvider.articles.isEmpty && newsProvider.isLoading) {
          return SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3, // Show 3 skeletons
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              final contextData = newsProvider.globalContexts[article.id];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: DeepAnalysisCard(article: article, contextData: contextData),
              );
            },
          ),
        );
      },
    );
  }
}
