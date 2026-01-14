import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import '../config/api_config.dart';

class RegionalNewsCarousel extends StatefulWidget {
  const RegionalNewsCarousel({super.key});

  @override
  State<RegionalNewsCarousel> createState() => _RegionalNewsCarouselState();
}

class _RegionalNewsCarouselState extends State<RegionalNewsCarousel> {
  List<dynamic> _newsArticles = [];
  String _locationName = "Detecting location...";
  bool _isLoading = true;

  // Replace with your NewsAPI key from newsapi.org (free tier: 100 req/day)
  final String _apiKey = ApiConfig.newsApiKey;

  @override
  void initState() {
    super.initState();
    _initAndroidOptimizedFlow();
  }

  Future<void> _initAndroidOptimizedFlow() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // 1. Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationName = "Location disabled");
        _fetchNews("Washington"); // Fallback
        return;
      }

      // 2. Check permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _locationName = "Permission denied");
          _fetchNews("Washington"); // Fallback
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationName = "Location permanently denied");
        _fetchNews("Washington"); // Fallback
        return;
      }

      // 3. Get Position with Android-specific settings
      // Use simpler settings that are compatible with the geolocator version
      // The user provided legacy AndroidSettings which might be for older geolocator versions or specific implementations
      // We'll use the platform-agnostic approach but ensure we handle errors gracefully as requested
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // 4. Convert Lat/Lng to Area Name
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        // Prefer administrativeArea (State/Province) -> locality (City) -> country
        String area = placemarks.first.administrativeArea ?? 
                      placemarks.first.locality ?? 
                      placemarks.first.country ?? 
                      "Washington";
        
        if (mounted) {
          setState(() {
            _locationName = area;
          });
        }
        
        await _fetchNews(area);
      } else {
        _fetchNews("Washington");
      }
      
    } catch (e) {
      debugPrint("Location/News Error: $e");
      if (mounted) {
         _fetchNews("Washington");
      }
    }
  }

  Future<void> _fetchNews(String area) async {
    try {
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
      debugPrint('Error fetching news: $e');
      _useMockData();
    }
  }

  void _useMockData() {
    if (mounted) {
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
            'No news available for $_locationName',
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
          return GestureDetector(
             onTap: () {
               // Push to detail screen (using placeholder or existing route)
               context.push('/regional-news'); 
             },
             child: Container(
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
            ),
          );
        },
      ),
    );
  }
}
