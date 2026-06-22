import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/location_provider.dart';
import '../providers/news_provider.dart' as np; // Alias to avoid any potential naming conflicts
import '../widgets/factual_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                // User Profile Card
                _buildProfileCard(),
                
                const SizedBox(height: 64),
                
                Text(
                  'Account & Security',
                  style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildAdaptiveFeedToggle(),
                
                const SizedBox(height: 16),
                
                _buildSettingItem(
                  icon: Icons.language,
                  title: 'Language',
                  onTap: () => context.push('/language'), // New route
                ),
                _buildSettingItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notification settings',
                  onTap: () => context.push('/notification-settings'),
                ),
                _buildSettingItem(
                  icon: Icons.delete_outline,
                  title: 'Clear Account Data',
                  onTap: () => context.push('/clear-data'), // New route
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy settings',
                  onTap: () {},
                ),
                
                // Extra sections for debug/info
                const SizedBox(height: 48),
                _buildSectionHeader('Support'),
                _buildSettingItem(
                  icon: Icons.help_outline,
                  title: 'Forgot Password',
                  onTap: () => context.push('/forgot-password'),
                ),
                _buildSettingItem(
                  icon: Icons.block_flipped,
                  title: 'Blocked Users',
                  onTap: () => context.push('/blocked-users'),
                ),
                
                const SizedBox(height: 100), // Space for logout button
              ],
            ),
            
            // Logout Button
            Positioned(
              bottom: 40,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  // Logout logic
                  context.go('/sign-in');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEFEFEF),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?u=georgios'),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'George Michael',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'georgiosmichael@gmail.com',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+3069065161615',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black26,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildAdaptiveFeedToggle() {
    final newsProvider = Provider.of<np.NewsProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: SwitchListTile(
        title: Text(
          'Adaptive Feed',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Personalize your feed based on your interests and location.',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.black45,
          ),
        ),
        value: newsProvider.usePersonalizedFeed,
        activeColor: Colors.black,
        onChanged: (value) {
          final locProvider = Provider.of<LocationProvider>(context, listen: false);
          newsProvider.togglePersonalizedFeed(
            value, 
            'default_user', 
            location: locProvider.currentLocation?.country,
          );
        },
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black12, size: 28),
          ],
        ),
      ),
    );
  }
}
