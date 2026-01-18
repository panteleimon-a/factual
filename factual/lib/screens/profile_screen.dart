import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/factual_header.dart';
import '../services/database_service.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

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
      // actually, userProvider should be used, but for stats we might need to wait for provider
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
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // Fallback display user
    final displayUser = user ?? User(
      id: 'guest',
      username: 'Guest User', 
      email: 'guest@factual.app',
      createdAt: DateTime.now(),
      lastActive: DateTime.now()
    );

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
                  image: displayUser.profileImage != null
                      ? DecorationImage(
                          image: NetworkImage(displayUser.profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: displayUser.profileImage == null
                    ? Center(
                        child: Text(
                          displayUser.username.isNotEmpty ? displayUser.username[0].toUpperCase() : 'U',
                          style: GoogleFonts.urbanist(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 24),

              // Username & Email
              Text(
                displayUser.username,
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                displayUser.email,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),

              // Statistics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Articles', '$_readCount'),
                  _buildStatColumn('Searches', '$_searchCount'),
                  _buildStatColumn('Saved', '45'), // Placeholder
                ],
              ),

              const SizedBox(height: 32),

              // Actions - Edit Profile
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

               // Actions - Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await userProvider.signOut();
                    if (context.mounted) context.go('/auth');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
