import 'package:flutter/material.dart';
import '../models/news_source.dart';

class SourceBadge extends StatelessWidget {
  final NewsSource source;
  final bool showCredibility;

  const SourceBadge({
    super.key,
    required this.source,
    this.showCredibility = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.apartment,
          size: 14,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(width: 4),
        Text(
          source.name,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        if (showCredibility) ...[
          const SizedBox(width: 6),
          _buildCredibilityIndicator(context),
        ],
      ],
    );
  }

  Widget _buildCredibilityIndicator(BuildContext context) {
    final score = source.credibilityScore;
    final color = score >= 0.7
        ? Theme.of(context).colorScheme.primary
        : score >= 0.4
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${(score * 100).toInt()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
