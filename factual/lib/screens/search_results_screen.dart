import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/bottom_nav_bar.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().search(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (newsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    newsProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => newsProvider.search(widget.query),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final articles = newsProvider.filteredArticles;

          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      'All Sources',
                      newsProvider.selectedSource == null,
                      () => newsProvider.setSourceFilter(null),
                    ),
                    const SizedBox(width: 8),
                    ..._getUniqueSources(newsProvider.articles).map((source) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          context,
                          source,
                          newsProvider.selectedSource == source,
                          () => newsProvider.setSourceFilter(source),
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    _buildFilterChip(
                      context,
                      'Positive',
                      newsProvider.selectedSentiment == 'positive',
                      () => newsProvider.setSentimentFilter(
                        newsProvider.selectedSentiment == 'positive' ? null : 'positive',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Negative',
                      newsProvider.selectedSentiment == 'negative',
                      () => newsProvider.setSentimentFilter(
                        newsProvider.selectedSentiment == 'negative' ? null : 'negative',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${articles.length} results for "${widget.query}"',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),

              // Article list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => newsProvider.search(widget.query),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: articles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      return NewsCard(
                        article: articles[index],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/article',
                            arguments: articles[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }

  List<String> _getUniqueSources(List<dynamic> articles) {
    return articles.map((a) => a.source.name as String).toSet().toList();
  }
}
