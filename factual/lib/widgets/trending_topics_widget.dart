import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TrendingTopicsWidget extends StatelessWidget {
  final Function(String)? onTopicTap;

  const TrendingTopicsWidget({
    super.key,
    this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.trendingTopics.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: userProvider.trendingTopics.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final topic = userProvider.trendingTopics[index];
                  return _buildTrendingTopic(context, topic);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingTopic(BuildContext context, String topic) {
    return ActionChip(
      label: Text(topic),
      avatar: Icon(
        Icons.trending_up,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline,
      ),
      onPressed: () {
        if (onTopicTap != null) {
          onTopicTap!(topic);
        }
      },
    );
  }
}
