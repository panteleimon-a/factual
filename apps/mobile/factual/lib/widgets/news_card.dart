import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/news_article.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Content (Expanded)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Metadata / Summary Snippet
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.black45,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Location / Source
                  _buildMetadataRow(context),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Right Image (Figma Spec: 205x104px)
            _buildArticleImage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      children: [
        if (article.location != null && article.location!.isNotEmpty) ...[
          const Icon(Icons.location_on_rounded, size: 14, color: Colors.black38),
          const SizedBox(width: 4),
          Text(
            article.location!,
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.black38),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          article.source.name,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '•',
          style: TextStyle(color: Colors.black12),
        ),
        const SizedBox(width: 8),
        Text(
          _getTimeAgo(article.publishedAt),
          style: GoogleFonts.roboto(fontSize: 12, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _buildArticleImage(BuildContext context) {
    if (article.imageUrl == null) {
      return Container(
        width: 140,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.image_not_supported_rounded, color: Colors.black12, size: 30),
      );
    }

    return Container(
      width: 140, // Scaled for mobile width while keeping aspect ratio
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(article.imageUrl!),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
