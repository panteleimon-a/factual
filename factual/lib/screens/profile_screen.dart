import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/factual_header.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _searchCount = 0;
  int _readCount = 0;
  String? _topTopic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileStats();
  }

  Future<void> _loadProfileStats() async {
    try {
      final db = DatabaseService();
      // Using 'default_user' as placeholder until Auth is fully integrated
      const userId = 'default_user';
      
      final searches = await db.getSearchCount(userId);
      final reads = await db.getInteractionCount(userId);
      final topics = await db.getTopInterestedTopics(userId, limit: 1);

      if (mounted) {
        setState(() {
          _searchCount = searches;
          _readCount = reads;
          _topTopic = topics.isNotEmpty ? topics.first : 'General';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/300?u=factual_user'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Name & Email
              Text(
                'John Doe',
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'john.doe@example.com',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Premium Info Section (Personalized Insights)
              _buildProfileItem(
                context, 
                'Stories Read', 
                _isLoading ? '...' : '$_readCount articles', 
                Icons.import_contacts_outlined
              ),
              _buildProfileItem(
                context, 
                'Search History', 
                _isLoading ? '...' : '$_searchCount queries', 
                Icons.history
              ),
              _buildProfileItem(
                context, 
                'Top Interest', 
                _isLoading ? '...' : _topTopic ?? 'None', 
                Icons.auto_graph_rounded
              ),
              
              const SizedBox(height: 48),
              
              // Actions
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Developer Analytics (Developer Only Feature)
              TextButton.icon(
                onPressed: () => context.push('/debug-analytics'),
                icon: const Icon(Icons.developer_mode, size: 18),
                label: Text(
                  'Developer Analytics',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black54,
                ),
              ),
              
              const SizedBox(height: 8),

              TextButton(
                onPressed: () {},
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black12, size: 20),
        ],
      ),
    );
  }
}
