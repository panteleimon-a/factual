import 'package:flutter/material.dart';
import '../widgets/news_card.dart';
import '../widgets/search_bar.dart';
import '../models/news_article.dart';
import '../models/news_source.dart';

class DemoWidgetsScreen extends StatelessWidget {
  const DemoWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Typography'),
            const SizedBox(height: 16),
            Text('Display Large (Brand Logo)', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text('Headline Large (Screen Title)', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('Headline Medium (Section Header)', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Title Large (Card Title)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Body Large (Summary)', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Body Medium (Body text)', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Colors'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildColorSwatch(context, Theme.of(context).colorScheme.primary, 'Primary (Green)'),
                _buildColorSwatch(context, Theme.of(context).colorScheme.error, 'Error (Red)'),
                _buildColorSwatch(context, Theme.of(context).colorScheme.surface, 'Surface'),
                _buildColorSwatch(context, Theme.of(context).colorScheme.onSurface, 'On Surface'),
                _buildColorSwatch(context, Theme.of(context).colorScheme.outline, 'Border'),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Components'),
            const SizedBox(height: 16),
            const Text('Search Bar:'),
            const SizedBox(height: 8),
            FigmaSearchBar(onFilterTap: () {}),
            const SizedBox(height: 24),
            
            const Text('News Card (Positive):'),
            const SizedBox(height: 8),
            NewsCard(
              article: _createDemoArticle('positive'),
            ),
            const SizedBox(height: 16),
            
            const Text('News Card (Negative):'),
            const SizedBox(height: 8),
            NewsCard(
              article: _createDemoArticle('negative'),
            ),
            const SizedBox(height: 16),
            
            const Text('News Card (Neutral, No Image):'),
            const SizedBox(height: 8),
            NewsCard(
              article: _createDemoArticle('neutral', withImage: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.outlineVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildColorSwatch(BuildContext context, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  NewsArticle _createDemoArticle(String sentiment, {bool withImage = true}) {
    return NewsArticle(
      id: '1',
      title: 'Global Climate Summit Reaches Historic Agreement on Emissions',
      summary: 'World leaders have unanimously agreed to aggressive carbon reduction targets by 2030.',
      content: 'Full content...',
      source: NewsSource(
        id: 's1',
        name: 'Reuters',
        url: '',
        country: 'us',
        language: 'en',
        category: 'general',
      ),
      url: '',
      imageUrl: withImage ? 'https://picsum.photos/200/300' : null,
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      sentiment: sentiment,
      sentimentScore: 0.8,
    );
  }
}
