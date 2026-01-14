import 'package:flutter/material.dart';
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
    // Figma "ArticleCard" specs:
    // - Horizontal layout
    // - Gap between items
    // - Image: Right side, Rounded pill shape
    // - Text: Left side
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        // Add divider at bottom to mimic list style if needed, or rely on ListView separator
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Content (Expanded)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sentiment Badge (Optional - added for feature completeness)
                  if (article.sentiment != 'neutral')
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getSentimentColor(context, article.sentiment).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _getSentimentColor(context, article.sentiment)),
                      ),
                      child: Text(
                        article.sentiment.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getSentimentColor(context, article.sentiment),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Title
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge, // H3 style
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Metadata Row
                  Row(
                    children: [
                      Text(
                        article.source.name,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTimeAgo(article.publishedAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Right Image (Figma Spec: 205x104px (scaled down), Rounded Pill)
            // Using aspect ratio to maintain shape
            if (article.imageUrl != null)
              Container(
                width: 120,
                height: 80, // Scaled down for mobile list view
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Pill-like
                  image: DecorationImage(
                    image: NetworkImage(article.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSentimentColor(BuildContext context, String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Theme.of(context).colorScheme.primary; // Green
      case 'negative':
        return Theme.of(context).colorScheme.error; // Red
      default:
        return Theme.of(context).colorScheme.outlineVariant; // Gray
    }
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
