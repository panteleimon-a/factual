import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class WorldwideNewsList extends StatefulWidget {
  const WorldwideNewsList({super.key});

  @override
  State<WorldwideNewsList> createState() => _WorldwideNewsListState();
}

class _WorldwideNewsListState extends State<WorldwideNewsList> {
  List<dynamic> _newsArticles = [];
  bool _isLoading = true;

  // Replace with your NewsAPI key
  final String _apiKey = ApiConfig.newsApiKey;

  @override
  void initState() {
    super.initState();
    _fetchWorldwideNews();
  }

  Future<void> _fetchWorldwideNews() async {
    try {
      // Fetch top headlines from a major source like BBC or CNN, or just general 'general' category
      // Using 'us' as a proxy for "worldwide" English news often works best for free tier, 
      // or language=en.
      final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?language=en&pageSize=10&apiKey=$_apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final List filtered = (data['articles'] as List)
            .where((a) => a['urlToImage'] != null && a['title'] != null && a['description'] != null)
            .take(5) // Take top 5 for the list
            .toList();

        if (mounted) {
          setState(() {
            _newsArticles = filtered;
            _isLoading = false;
          });
        }
      } else {
        _useMockData();
      }
    } catch (e) {
      debugPrint("Error fetching worldwide news: $e");
      _useMockData();
    }
  }

  void _useMockData() {
    if (mounted) {
      setState(() {
        _newsArticles = [
          {
            'title': 'Global Summit Reaches Historic Agreement on Climate Action',
            'description': 'Leaders from 190 nations have signed a binding pact to reduce emissions by 50% within the next decade.',
            'urlToImage': 'https://via.placeholder.com/150x150/4A90E2/FFFFFF?text=Climate',
            'source': {'name': 'Global News'},
            'publishedAt': '2025-01-14T10:00:00Z',
          },
          {
            'title': 'Tech Giants Unveil Revolutionary AI Assistant',
            'description': 'A joint venture has produced a new AI model capable of complex reasoning and creative problem solving.',
            'urlToImage': 'https://via.placeholder.com/150x150/50C878/FFFFFF?text=AI+Tech',
            'source': {'name': 'Tech Weekly'},
            'publishedAt': '2025-01-14T09:30:00Z',
          },
          {
            'title': 'SpaceX Successfully Lands Starship on Mars',
            'description': 'The first uncrewed mission to the red planet has touched down safely, marking a new era of space exploration.',
            'urlToImage': 'https://via.placeholder.com/150x150/FF6B6B/FFFFFF?text=Mars',
            'source': {'name': 'Space Times'},
            'publishedAt': '2025-01-14T08:15:00Z',
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _newsArticles.length,
      itemBuilder: (context, index) {
        final article = _newsArticles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Image.network(
                    article['urlToImage'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'] ?? 'No Title',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article['description'] ?? '',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article['source']?['name'] ?? 'Unknown Source',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
