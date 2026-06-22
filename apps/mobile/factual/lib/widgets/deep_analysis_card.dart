import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Add Provider
import '../models/news_article.dart';
import '../providers/news_provider.dart'; // Add NewsProvider
import 'package:go_router/go_router.dart';
import '../services/user_activity_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DeepAnalysisCard extends StatefulWidget {
  final NewsArticle article;
  final Map<String, dynamic>? contextData;

  const DeepAnalysisCard({
    super.key,
    required this.article,
    this.contextData,
  });

  @override
  State<DeepAnalysisCard> createState() => _DeepAnalysisCardState();
}

class _DeepAnalysisCardState extends State<DeepAnalysisCard> {
  @override
  void initState() {
    super.initState();
    // Lazy load context if missing
    if (widget.contextData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<NewsProvider>(context, listen: false).analyzeArticle(widget.article.id);
      });
    }
  }

  @override
  void didUpdateWidget(DeepAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If article changed or context was null and is still null, re-trigger
    if (widget.article.id != oldWidget.article.id && widget.contextData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<NewsProvider>(context, listen: false).analyzeArticle(widget.article.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final userActivity = UserActivityService();
        userActivity.trackArticleView('default_user', widget.article.id, widget.article.topics);
        context.push('/article-detail', extra: widget.article);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Content: Title/Source + Summary (Utility 2)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    widget.article.source.name.toUpperCase(),
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black38,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Utility 2: AI Abstract
                  Text(
                    widget.contextData?['abstract'] ?? widget.article.summary,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Content: Reproduction Graph (Utility 3)
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 160,
                child: _buildGraphContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphContent() {
    // 1. Loading State
    if (widget.contextData == null) {
      return _buildGraphLoading();
    }
    
    // 2. Failure/Empty State (contextData is not null but empty, or graphData missing)
    if (widget.contextData!.isEmpty || widget.contextData!['graphData'] == null) {
      return Center(
        child: Text(
          'Analysis Unavailable',
          style: GoogleFonts.robotoCondensed(fontSize: 10, color: Colors.black26),
        ),
      );
    }
    
    // 3. Success State
    return _buildReproductionGraph(widget.contextData!['graphData'] as List?);
  }

  Widget _buildGraphLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black12),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing spread...',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoCondensed(fontSize: 9, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildReproductionGraph(List? graphData) {
    if (graphData == null || graphData.isEmpty) return const SizedBox.shrink();

    List<FlSpot> spots = [];
    try {
      // Parse data points
      for (var item in graphData) {
        if (item['datetime'] != null && item['velocity'] != null) {
          final date = DateTime.parse(item['datetime'].toString());
          final velocity = (item['velocity'] as num).toDouble();
          spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), velocity));
        }
      }
      
      // Sort by time just in case
      spots.sort((a, b) => a.x.compareTo(b.x));
      
      if (spots.isEmpty) return const SizedBox.shrink();
      
    } catch (e) {
      print('Graph data parsing error: $e');
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SPREAD VELOCITY',
            style: GoogleFonts.robotoCondensed(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.black26,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.black87,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
              minY: 0,
              maxY: 100, // Velocity is 0-100
              lineTouchData: LineTouchData(
                enabled: false, // Minimal, no interaction for now
              ),
            ),
          ),
        ),

        // Time Labels: Start - Peak (if significant) - Today
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(spots.first.x),
                style: GoogleFonts.robotoCondensed(fontSize: 8, color: Colors.black38),
              ),
              if (_getPeakSpot(spots) != null)
                Column(
                  children: [
                    Text(
                      'PEAK',
                      style: GoogleFonts.robotoCondensed(fontSize: 6, color: Colors.black26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(_getPeakSpot(spots)!.x),
                      style: GoogleFonts.robotoCondensed(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              Text(
                'TODAY',
                style: GoogleFonts.robotoCondensed(fontSize: 8, color: Colors.black38),
              ),
            ],
          ),
        ),
      ],
    );
  }

  FlSpot? _getPeakSpot(List<FlSpot> spots) {
    if (spots.isEmpty) return null;
    FlSpot peak = spots.first;
    for (var spot in spots) {
      if (spot.y > peak.y) peak = spot;
    }
    // Only show peak if it's not the start or end (approx) to avoid overlap
    if (peak == spots.first || peak == spots.last) return null;
    return peak;
  }

  String _formatDate(double ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    return DateFormat('MMM d').format(date).toUpperCase();
  }
}



