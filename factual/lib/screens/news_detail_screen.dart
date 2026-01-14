import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final String articleId;
  const NewsDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article Details')),
      body: Center(child: Text('Details for article: $articleId')),
    );
  }
}
