import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/factual_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _locationDiscovery = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            Text(
              'Settings',
              style: GoogleFonts.roboto(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 48),
            
            _buildSectionHeader('Preferences'),
            _buildSwitchItem('Push Notifications', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
            _buildSwitchItem('Email Updates', _emailUpdates, (v) => setState(() => _emailUpdates = v)),
            _buildSwitchItem('Location Discovery', _locationDiscovery, (v) => setState(() => _locationDiscovery = v)),
            
            const SizedBox(height: 40),
            
            _buildSectionHeader('Account'),
            _buildLinkItem('Account Details'),
            _buildLinkItem('Privacy Policy'),
            _buildLinkItem('Terms of Service'),
            
            const SizedBox(height: 40),
            
            _buildSectionHeader('Debug (Pilot)'),
            _buildLinkItem('Analytics & Export', onTap: () => context.push('/debug-analytics')),
            
            const SizedBox(height: 40),
            
            _buildSectionHeader('App Info'),
            _buildInfoItem('Version', '1.0.0 (Build 42)'),
            _buildInfoItem('Build Date', 'Dec 20, 2024'),
            
            const SizedBox(height: 64),
            
            Center(
              child: Text(
                'factual',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '© 2024 factual News Inc.',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.black26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black26,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 17,
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

  Widget _buildInfoItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
