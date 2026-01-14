import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/search_query.dart';

class PastSearchesWidget extends StatelessWidget {
  final int? limit;
  final Function(SearchQuery)? onSearchTap;

  const PastSearchesWidget({
    super.key,
    this.limit,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.searchHistory.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No search history yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Past Searches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showClearDialog(context, userProvider),
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: limit != null 
                    ? (userProvider.searchHistory.length > limit! 
                        ? limit 
                        : userProvider.searchHistory.length)
                    : userProvider.searchHistory.length,
                itemBuilder: (context, index) {
                  final search = userProvider.searchHistory[index];
                  return _buildSearchItem(context, search, userProvider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchItem(
    BuildContext context,
    SearchQuery search,
    UserProvider userProvider,
  ) {
    return Dismissible(
      key: Key(search.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => userProvider.deleteSearch(search.id),
      child: ListTile(
        leading: Icon(
          Icons.history,
          color: _getSentimentColor(search.sentiment),
        ),
        title: Text(search.query),
        subtitle: Text(
          '${_formatTime(search.timestamp)}${search.location != null ? ' • ${search.location}' : ''}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getSentimentColor(search.sentiment).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            search.sentiment,
            style: TextStyle(
              color: _getSentimentColor(search.sentiment),
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // Re-execute search
          // This would navigate to search screen with this query
        },
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showClearDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text('Are you sure you want to clear all search history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              userProvider.clearSearchHistory();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
