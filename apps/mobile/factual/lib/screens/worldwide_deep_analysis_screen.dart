import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/factual_header.dart';
import '../widgets/deep_analysis_card.dart';

class WorldwideDeepAnalysisScreen extends StatelessWidget {
  const WorldwideDeepAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          final analyzedArticles = provider.articles.take(10).toList();
          final remainingArticles = provider.articles.skip(10).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GLOBAL DEEP ANALYSIS',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: Colors.black26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Top 10 Worldwide',
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verified summaries and reproduction lifecycle graphs generated per SR Editorial Protocol.',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Analyzed Cards
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = analyzedArticles[index];
                    final contextData = provider.globalContexts[article.id];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DeepAnalysisCard(article: article, contextData: contextData),
                    );
                  },
                  childCount: analyzedArticles.length,
                ),
              ),

              if (remainingArticles.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                    child: Text(
                      'MORE WORLDWIDE NEWS',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.black26,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = remainingArticles[index];
                      return _buildSimpleNewsItem(context, article);
                    },
                    childCount: remainingArticles.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSimpleNewsItem(BuildContext context, dynamic article) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.source.name.toUpperCase(),
            style: GoogleFonts.robotoCondensed(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            article.title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
