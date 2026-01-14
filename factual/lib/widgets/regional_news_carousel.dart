import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegionalNewsCarousel extends StatefulWidget {
  const RegionalNewsCarousel({super.key});

  @override
  State<RegionalNewsCarousel> createState() => _RegionalNewsCarouselState();
}

class _RegionalNewsCarouselState extends State<RegionalNewsCarousel> {
  List<dynamic> _newsArticles = [];
  String _userCountry = 'Greece';
  String _userArea = 'Greece';
  bool _isLoading = true;

  // Replace with your NewsAPI key from newsapi.org (free tier: 100 req/day)
  final String _apiKey = 'YOUR_NEWS_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _fetchLocationAndNews();
  }

  Future<void> _fetchLocationAndNews() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.getCurrentLocation();
      
      if (locationProvider.currentLocation != null) {
        // Get country and area from coordinates
        final placemarks = await placemarkFromCoordinates(
          locationProvider.currentLocation!.latitude,
          locationProvider.currentLocation!.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          String country = placemark.country ?? 'Greece';
          String area = placemark.administrativeArea ?? placemark.locality ?? country;
          
          setState(() {
            _userCountry = country;
            _userArea = area;
          });
          
          // Fetch news for this area
          await _fetchNews(area);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
    
    // Fallback: fetch news for default location
    await _fetchNews(_userArea);
  }

  Future<void> _fetchNews(String area) async {
    try {
      // NewsAPI endpoint - fetch top news for the area
      final url = Uri.parse(
        'https://newsapi.org/v2/everything?q=$area&sortBy=publishedAt&pageSize=10&apiKey=$_apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Filter: Only articles with images, take first 3
        final List filtered = (data['articles'] as List)
            .where((a) => a['urlToImage'] != null && a['urlToImage'].toString().isNotEmpty)
            .take(3)
            .toList();

        setState(() {
          _newsArticles = filtered;
          _isLoading = false;
        });
      } else {
        // Fallback to mock data if API fails
        _useMockData();
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
      _useMockData();
    }
  }

  void _useMockData() {
    setState(() {
      _newsArticles = [
        {
          'title': 'Συνάντηση Trump-Putin στην Αλάσκα',
          'urlToImage': 'https://via.placeholder.com/300x200/4A90E2/FFFFFF?text=News+1',
          'source': {'name': 'Mock News'},
        },
        {
          'title': 'Wonderplant: Πράσινο φως από την ΕΕ για τη mega επένδυση 165-εκατ. στην Πτολεμαΐδα',
          'urlToImage': 'https://via.placeholder.com/300x200/50C878/FFFFFF?text=News+2',
          'source': {'name': 'Mock News'},
        },
        {
          'title': 'Νέες εξελίξεις στην ελληνική οικονομία',
          'urlToImage': 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=News+3',
          'source': {'name': 'Mock News'},
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (_newsArticles.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No news available for $_userArea',
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _newsArticles.length,
        itemBuilder: (context, index) {
          final article = _newsArticles[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Image.network(
                      article['urlToImage'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  article['title'] ?? 'No title',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
