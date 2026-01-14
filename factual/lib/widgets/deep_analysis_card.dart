import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/news_article.dart';
import 'package:go_router/go_router.dart';

class DeepAnalysisCard extends StatelessWidget {
  final NewsArticle article;
  final Map<String, dynamic>? contextData;

  const DeepAnalysisCard({
    super.key,
    required this.article,
    this.contextData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/article-detail', extra: article),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Content: Title/Source + Summary (Utility 2)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    article.source.name.toUpperCase(),
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black38,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Utility 2: AI Abstract
                  Text(
                    contextData?['abstract'] ?? article.summary,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Content: Reproduction Graph (Utility 3)
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 140,
                child: contextData == null 
                  ? _buildGraphLoading()
                  : _buildReproductionGraph(contextData!['graphData'] as List?),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black12),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing spread...',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoCondensed(fontSize: 9, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildReproductionGraph(List? graphData) {
    if (graphData == null || graphData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REPRODUCTION',
          style: GoogleFonts.robotoCondensed(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.black26,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: graphData.map((data) {
              final double volume = (data['volume'] as num).toDouble();
              final double heightFactor = (volume / 20).clamp(0.1, 1.0);
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 8,
                    height: 80 * heightFactor,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['time'].toString(),
                    style: GoogleFonts.robotoCondensed(fontSize: 8, color: Colors.black38),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Spread: ${graphData.last['volume']} sources',
          style: GoogleFonts.roboto(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black45),
        ),
      ],
    );
  }
}
