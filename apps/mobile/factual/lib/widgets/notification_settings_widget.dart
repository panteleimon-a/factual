import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  final List<String> _availableTopics = [
    'Breaking News',
    'Politics',
    'Technology',
    'Business',
    'Sports',
    'Entertainment',
    'Science',
    'Health',
  ];

  Set<String> _subscribedTopics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscribedTopics();
  }

  Future<void> _loadSubscribedTopics() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final topics = await userProvider.getSubscribedTopics();
    setState(() {
      _subscribedTopics = topics.toSet();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Notification Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Get notified about topics you care about',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ..._availableTopics.map((topic) {
                final isSubscribed = _subscribedTopics.contains(topic);
                return CheckboxListTile(
                  title: Text(topic),
                  value: isSubscribed,
                  onChanged: (value) => _toggleSubscription(topic, value ?? false),
                  secondary: const Icon(Icons.label_outline),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSubscription(String topic, bool subscribe) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      if (subscribe) {
        _subscribedTopics.add(topic);
      } else {
        _subscribedTopics.remove(topic);
      }
    });

    if (subscribe) {
      await userProvider.subscribeToTopic(topic);
    } else {
      await userProvider.unsubscribeFromTopic(topic);
    }
  }
}
