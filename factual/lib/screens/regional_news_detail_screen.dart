import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/factual_header.dart';
import '../widgets/news_card.dart';
import '../providers/news_provider.dart';

class RegionalNewsDetailScreen extends StatelessWidget {
  const RegionalNewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: Consumer<NewsProvider>(
          builder: (context, newsProvider, child) {
            if (newsProvider.isLoading && newsProvider.articles.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            final regionalArticles = newsProvider.articles.where((a) => a.location != null || a.latitude != null).toList();
            
            // Fallback to top headlines if none marked as regional
            final displayArticles = regionalArticles.isNotEmpty ? regionalArticles : newsProvider.articles;

            if (displayArticles.isEmpty) {
              return Center(
                child: Text(
                  'No regional news at this time.',
                  style: GoogleFonts.roboto(color: Colors.black54),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: displayArticles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 40),
              itemBuilder: (context, index) {
                return NewsCard(
                  article: displayArticles[index],
                  onTap: () {
                    context.push('/article-detail', extra: displayArticles[index]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
