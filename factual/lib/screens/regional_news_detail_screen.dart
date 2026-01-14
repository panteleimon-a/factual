import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class RegionalNewsDetailScreen extends StatelessWidget {
  const RegionalNewsDetailScreen({super.key});

  // Mock detailed Greek news data
  List<Map<String, String>> _getDetailedGreekNews() {
    return [
      {
        'title': 'Trump and Xi Signal Diplomatic Reset Amid Trade Tensions',
        'description': 'In a high-stakes diplomatic encounter, Chinese President Xi Jinping and U.S. President Donald Trump convened in Geneva today for a closed-door summit aimed at easing escalating tensions between the world\'s two largest economies. The meeting, which lasted over three hours, covered a wide range of topics including trade imbalances, cybersecurity concerns, and regional security in the Indo-Pacific.',
        'image': 'https://via.placeholder.com/200x100/4A90E2/FFFFFF?text=Trump-Xi',
        'location': '',
      },
      {
        'title': 'Macron Reappoints Lecornu Amid Political Turmoil',
        'description': 'In a dramatic turn of events, French President Emmanuel Macron has reappointed Sebastien Lecornu as Prime Minister, just days after his resignation. The move comes amid mounting political instability, with Lecornu\'s initial tenure ending abruptly following resistance from opposition parties and a fractured coalition',
        'image': 'https://via.placeholder.com/200x100/50C878/FFFFFF?text=Macron',
        'location': '',
      },
      {
        'title': 'Dendias Pushes for Military Reform Amid Rising Tensions',
        'description': 'Greek Minister of National Defence Nikos Dendias has unveiled a sweeping plan aimed at modernizing the country\'s armed forces and tightening regulations around military service. Speaking before Parliament, Dendias highlighted a troubling trend: over 74,000 Greek citizens have evaded conscription in recent years, citing psychological or medical grounds.',
        'image': 'https://via.placeholder.com/200x100/FF6B6B/FFFFFF?text=Dendias',
        'location': 'Near you',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final news = _getDetailedGreekNews();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back/Clock Icon
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.access_time, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  const Spacer(),
                  
                  // factual Logo (clickable)
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Text(
                      'factual',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 28 / 32,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Notification Icon
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Profile Avatar
                  GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 20, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            
            // News List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: news.length,
                separatorBuilder: (context, index) => const SizedBox(height: 50),
                itemBuilder: (context, index) {
                  final article = news[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              article['title']!,
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Description
                            Text(
                              article['description']!,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                height: 1.0,
                              ),
                            ),
                            if (article['location']!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    article['location']!,
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 205,
                          height: 104,
                          color: Colors.grey[300],
                          child: Image.network(
                            article['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 40, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
