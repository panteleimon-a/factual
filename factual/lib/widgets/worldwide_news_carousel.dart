import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'deep_analysis_card.dart';

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
        final articles = newsProvider.articles.take(3).toList();
        if (articles.isEmpty) return const SizedBox.shrink();

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
