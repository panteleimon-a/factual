import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/news_article.dart';
import '../providers/news_provider.dart';
import '../services/user_activity_service.dart';
import 'deep_analysis_card.dart';

class WorldwideNewsItem extends StatefulWidget {
  final NewsArticle article;

  const WorldwideNewsItem({super.key, required this.article});

  @override
  State<WorldwideNewsItem> createState() => _WorldwideNewsItemState();
}

class _WorldwideNewsItemState extends State<WorldwideNewsItem> {
  bool _isAnalyzing = false;
  bool _isExpanded = false;

  Future<void> _handleAnalyze() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _isExpanded = true; 
    });

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.analyzeArticle(widget.article.id);

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, _) {
        final contextData = newsProvider.globalContexts[widget.article.id];
        final bool hasAnalysis = contextData != null;

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                final userActivity = UserActivityService();
                userActivity.trackArticleView('default_user', widget.article.id, widget.article.topics);
                context.push('/article-detail', extra: widget.article);
              },
              child: Container(
                color: Colors.transparent, // Hit test for full width
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[100],
                        child: widget.article.imageUrl != null
                            ? Image.network(
                                widget.article.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                              )
                            : const Icon(Icons.article_outlined, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.article.title,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.article.summary,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                widget.article.source.name.toUpperCase(),
                                style: GoogleFonts.robotoCondensed(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const CircleAvatar(radius: 1.5, backgroundColor: Colors.black26),
                              const SizedBox(width: 8),
                              Text(
                                _getTimeAgo(widget.article.publishedAt),
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                              const Spacer(),
                              // Analyze Button
                              if (!hasAnalysis && !_isAnalyzing)
                                GestureDetector(
                                  onTap: _handleAnalyze,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.auto_graph_rounded, size: 14, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Analyze Spread',
                                          style: GoogleFonts.roboto(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_isAnalyzing)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Expanded Analysis Section
            if (_isExpanded || hasAnalysis) ...[
              const SizedBox(height: 16),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SizedBox(
                   // Use fixed height for graph or auto content
                   height: 160,
                   width: double.infinity,
                   child: hasAnalysis 
                    ? DeepAnalysisCard(article: widget.article, contextData: contextData)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.black12),
                            const SizedBox(height: 8),
                            Text(
                              'Generating Reproduction Graph...',
                              style: GoogleFonts.roboto(fontSize: 12, color: Colors.black45),
                            )
                          ],
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 20),
            ] else 
              const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
