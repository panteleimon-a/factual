import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/factual_header.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _breakingNews = true;
  bool _personalizedAlerts = true;
  bool _mentions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Notifications',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildToggle('Push Notifications', _pushEnabled, (v) => setState(() => _pushEnabled = v)),
                  _buildToggle('Email Notifications', _emailEnabled, (v) => setState(() => _emailEnabled = v)),
                  
                  const SizedBox(height: 32),
                  Text(
                    'NEWS PREFERENCES',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black26,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildToggle('Breaking News', _breakingNews, (v) => setState(() => _breakingNews = v)),
                  _buildToggle('Personalized Alerts', _personalizedAlerts, (v) => setState(() => _personalizedAlerts = v)),
                  
                  const SizedBox(height: 32),
                  Text(
                    'COMMUNITY',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black26,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildToggle('Mentions & Replies', _mentions, (v) => setState(() => _mentions = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
