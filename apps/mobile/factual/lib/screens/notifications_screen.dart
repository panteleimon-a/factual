import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/factual_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Your Topics Section
              _buildSectionHeader('Your Topics'),
              _buildTopicItem(
                imageUrl: 'https://via.placeholder.com/60',
                title: 'Gaza Ceasefire Agreement -',
                timeAgo: '2h ago',
              ),
              _buildTopicItem(
                imageUrl: 'https://via.placeholder.com/60',
                title: 'Climate Summit 2025 - BBC',
                timeAgo: '5h ago',
              ),

              const SizedBox(height: 24),

              // Your Published Prompts Section
              _buildSectionHeader('Your Published Prompts'),
              _buildPublishedPrompt(
                avatar: 'https://via.placeholder.com/40',
                responses: 12,
                prompt: '"What are the implications of AI regulation?"',
                likeCount: 45,
                commentCount: 12,
                timeAgo: '3h ago',
              ),
              _buildPublishedPrompt(
                avatar: 'https://via.placeholder.com/40',
                responses: 8,
                prompt: '"How will renewable energy change global politics?"',
                likeCount: 32,
                commentCount: 8,
                timeAgo: '6h ago',
              ),

              const SizedBox(height: 24),

              // Recommended for you Section
              _buildSectionHeader('Recommended for you'),
              _buildRecommendation(
                imageUrl: 'https://via.placeholder.com/60',
                title: 'New Discovery in Quantum Computing Could Revolutionize Technology',
                source: 'Tech Review',
                timeAgo: '1h ago',
              ),
              _buildRecommendation(
                imageUrl: 'https://via.placeholder.com/60',
                title: 'Global Leaders Meet to Discuss Climate Action',
                source: 'World News',
                timeAgo: '3h ago',
              ),
              _buildRecommendation(
                imageUrl: 'https://via.placeholder.com/60',
                title: 'Economic Growth Projections Exceed Expectations',
                source: 'Finance Times',
                timeAgo: '4h ago',
              ),

              const SizedBox(height: 24),

              // "All caught up" message
              Center(
                child: Text(
                  'All caught up!',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: const Color(0xFF929292),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTopicItem({
    required String imageUrl,
    required String title,
    required String timeAgo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: const Color(0xFFE0E0E0),
              child: const Icon(Icons.article, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: const Color(0xFF929292),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF929292)),
        ],
      ),
    );
  }

  Widget _buildPublishedPrompt({
    required String avatar,
    required int responses,
    required String prompt,
    required int likeCount,
    required int commentCount,
    required String timeAgo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE0E0E0),
            child: const Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$responses responses - $prompt',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 14, color: const Color(0xFF929292)),
                    const SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: const Color(0xFF929292),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined, size: 14, color: const Color(0xFF929292)),
                    const SizedBox(width: 4),
                    Text(
                      '$commentCount',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: const Color(0xFF929292),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: const Color(0xFF929292),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF929292)),
        ],
      ),
    );
  }

  Widget _buildRecommendation({
    required String imageUrl,
    required String title,
    required String source,
    required String timeAgo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular (12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: const Color(0xFFE0E0E0),
              child: const Icon(Icons.article_outlined, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$source · $timeAgo',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: const Color(0xFF929292),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF929292)),
        ],
      ),
    );
  }
}
