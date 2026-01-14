import 'package:flutter/material.dart';

class SentimentIndicator extends StatelessWidget {
  final String sentiment;
  final double? score;
  final bool showLabel;

  const SentimentIndicator({
    super.key,
    required this.sentiment,
    this.score,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getSentimentColor(context);
    final icon = _getSentimentIcon();
    final label = sentiment.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSentimentColor(BuildContext context) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Theme.of(context).colorScheme.primary; // Green
      case 'negative':
        return Theme.of(context).colorScheme.error; // Red
      default:
        return Theme.of(context).colorScheme.outlineVariant; // Gray
    }
  }

  IconData _getSentimentIcon() {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Icons.trending_up;
      case 'negative':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}
