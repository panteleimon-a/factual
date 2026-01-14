import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/factual_header.dart';
import '../providers/news_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Politics', 'icon': Icons.account_balance},
    {'name': 'Tech', 'icon': Icons.memory},
    {'name': 'Health', 'icon': Icons.monitor_heart},
    {'name': 'Science', 'icon': Icons.science},
    {'name': 'Sports', 'icon': Icons.sports_basketball},
    {'name': 'Business', 'icon': Icons.business},
  ];

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    context.push('/query-analysis', extra: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: _handleSearch,
                  style: GoogleFonts.roboto(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search news, topics, or regions',
                    hintStyle: GoogleFonts.roboto(color: Colors.black38),
                    prefixIcon: const Icon(Icons.search, color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'CATEGORIES',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black26,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return _buildCategoryChip(cat['name'], cat['icon']);
                },
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'TRENDING TOPICS',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black26,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildTrendingItem('Global Economy 2024'),
              _buildTrendingItem('AI Regulation Debates'),
              _buildTrendingItem('Climate Summit Outcomes'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _handleSearch(label),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(String topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => _handleSearch(topic),
        child: Row(
          children: [
            const Icon(Icons.trending_up, color: Colors.black26, size: 20),
            const SizedBox(width: 16),
            Text(
              topic,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black12, size: 24),
          ],
        ),
      ),
    );
  }
}
