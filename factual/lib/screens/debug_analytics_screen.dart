import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../widgets/factual_header.dart';

class DebugAnalyticsScreen extends StatefulWidget {
  const DebugAnalyticsScreen({super.key});

  @override
  State<DebugAnalyticsScreen> createState() => _DebugAnalyticsScreenState();
}

class _DebugAnalyticsScreenState extends State<DebugAnalyticsScreen> {
  final String _userId = 'default_user';
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      final db = DatabaseService();
      
      final topTopics = await db.getTopInterestedTopics(_userId);
      final searchHistory = await db.getUserSearchHistory(_userId, limit: 100);
      final popularSearches = await db.getGlobalPopularSearches(limit: 20);
      
      setState(() {
        _analytics = {
          'userId': _userId,
          'topTopics': topTopics,
          'searchCount': searchHistory.length,
          'recentSearches': searchHistory.take(10).map((q) => {
            'query': q.query,
            'sentiment': q.sentiment,
            'timestamp': q.timestamp.toIso8601String(),
          }).toList(),
          'popularSearches': popularSearches,
          'timestamp': DateTime.now().toIso8601String(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _analytics = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  Future<void> _exportDatabaseCopy() async {
    setState(() => _isExporting = true);
    
    try {
      final db = await DatabaseService().database;
      final dbPath = db.path;
      
      // Create a copy in external storage
      final directory = await getApplicationDocumentsDirectory();
      final exportPath = '${directory.path}/factual_export_${DateTime.now().millisecondsSinceEpoch}.db';
      
      final dbFile = File(dbPath);
      await dbFile.copy(exportPath);
      
      // Share the database file
      await Share.shareXFiles(
        [XFile(exportPath)],
        subject: 'factual Database Export',
        text: 'User activity database export for pilot tracking',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAnalyticsJSON() async {
    setState(() => _isExporting = true);
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportPath = '${directory.path}/factual_analytics_${DateTime.now().millisecondsSinceEpoch}.json';
      
      final file = File(exportPath);
      await file.writeAsString(JsonEncoder.withIndent('  ').convert(_analytics));
      
      await Share.shareXFiles(
        [XFile(exportPath)],
        subject: 'factual Analytics Export',
        text: 'User analytics JSON export',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analytics exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Analytics (Pilot)',
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User activity tracking for pilot phase',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Export Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportDatabaseCopy,
                          icon: const Icon(Icons.storage),
                          label: const Text('Export DB File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportAnalyticsJSON,
                          icon: const Icon(Icons.analytics),
                          label: const Text('Export JSON'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Analytics Display
                  if (_analytics != null) ...[
                    _buildSection(
                      'Top Interested Topics',
                      (_analytics!['topTopics'] as List).isEmpty
                          ? ['No data yet']
                          : (_analytics!['topTopics'] as List).cast<String>(),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildInfoCard('Total Searches', '${_analytics!['searchCount']}'),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      'Recent Searches',
                      (_analytics!['recentSearches'] as List).map((s) {
                        return '${s['query']} (${s['sentiment']}) - ${_formatTimestamp(s['timestamp'])}';
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• $item',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String iso) {
    final dt = DateTime.parse(iso);
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
