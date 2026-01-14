import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class RegionalNewsCarousel extends StatelessWidget {
  const RegionalNewsCarousel({super.key});

  // Mock Greek news data (will be replaced with actual API call)
  List<Map<String, String>> _getMockGreekNews() {
    return [
      {
        'title': 'Συνάντηση Trump-Putin στην Αλάσκα',
        'image': 'https://via.placeholder.com/300x200/4A90E2/FFFFFF?text=News+1',
      },
      {
        'title': 'Wonderplant: Πράσινο φως από την ΕΕ για τη mega επένδυση 165-εκατ. στην Πτολεμαΐδα',
        'image': 'https://via.placeholder.com/300x200/50C878/FFFFFF?text=News+2',
      },
      {
        'title': 'Νέες εξελίξεις στην ελληνική οικονομία',
        'image': 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=News+3',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final news = _getMockGreekNews();
    
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final article = news[index];
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
                      article['image']!,
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
                  article['title']!,
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
