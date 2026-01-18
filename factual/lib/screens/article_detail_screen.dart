import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/news_article.dart';
import '../models/search_query.dart';
import '../widgets/factual_header.dart';
import '../widgets/bias_gauge.dart';
import '../services/llm_service.dart';
import '../services/database_service.dart';
import '../services/user_activity_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  Map<String, dynamic>? _analysis;
  List<Map<String, dynamic>>? _reproductionGraph;
  bool _isAnalyzing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performAnalysis();
    _logInteraction();
  }

  Future<void> _logInteraction() async {
    try {
      final db = DatabaseService();
      // Using 'default_user' for now, in real app would be authenticated user ID
      await db.logArticleView('default_user', widget.article.id, widget.article.topics);
      
      // Add article to search history so it appears in chat hub
      final searchQuery = SearchQuery(
        id: const Uuid().v4(),
        userId: 'default_user',
        query: widget.article.title,
        sentiment: widget.article.sentiment,
        timestamp: DateTime.now(),
        relatedArticleIds: [widget.article.id],
      );
      await db.insertSearchQuery(searchQuery);
      
      // Dual-Tracking: Firestore + Analytics (Personalization)
      final userActivity = UserActivityService();
      await userActivity.trackArticleView(
        'default_user', 
        widget.article.id, 
        widget.article.topics,
      );
    } catch (e) {
      print('Interaction logging failed: $e');
    }
  }

  Future<void> _performAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final llm = Provider.of<LLMService>(context, listen: false);
      final result = await llm.generateAnalysis(widget.article);
      final graph = await llm.getReproductionGraph(widget.article);
      if (mounted) {
        setState(() {
          _analysis = result;
          _reproductionGraph = graph;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Analysis failed: $e';
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const factualHeader(),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Image Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.article.title,
                          style: GoogleFonts.roboto(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildCircularImage(),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  _buildSourceInfo(),
                  
                  const SizedBox(height: 32),

                  if (_isAnalyzing)
                    _buildLoadingShimmer()
                  else if (_error != null)
                    _buildErrorState()
                  else if (_analysis != null)
                    _buildAnalysisContent()
                  else
                    _buildOriginalContent(),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
            
            // Bottom Right Action
            Positioned(
              bottom: 32,
              right: 24,
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.article.source.name.toUpperCase(),
            style: GoogleFonts.robotoCondensed(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${DateTime.now().difference(widget.article.publishedAt).inHours} hours ago',
          style: GoogleFonts.roboto(fontSize: 12, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _buildAnalysisContent() {
    final summary = _analysis!['summary'] ?? widget.article.summary;
    final bias = _analysis!['bias'] ?? {};
    final keyFacts = _analysis!['keyFacts'] as List? ?? [];
    final verdict = _analysis!['verdict'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium AI Summary
        Container(
          padding: const EdgeInsets.only(left: 16),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.black, width: 4)),
          ),
          child: Text(
            summary,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 1.6,
            ),
          ),
        ),
        
        const SizedBox(height: 48),
        
        // Bias Assessment with Gauge
        if (bias['type'] != null)
           _buildAnalysisSection(
            title: 'Bias Assessment',
            icon: Icons.search_rounded,
            content: bias['analysis'],
            customWidget: BiasGauge(biasType: bias['type'].toString()),
          ),

        const SizedBox(height: 24),

        // Key Facts with Citations
        if (keyFacts.isNotEmpty)
          _buildAnalysisSection(
            title: 'Verified Key Facts',
            isList: true,
            listItems: keyFacts.cast<String>(),
            icon: Icons.verified_user_outlined,
            hasCitation: true,
          ),

        const SizedBox(height: 24),

        // Credibility Verdict
        if (verdict.isNotEmpty)
          _buildAnalysisSection(
            title: 'factual verdict',
            content: verdict,
            icon: Icons.gavel_rounded,
            headerColor: Colors.black,
          ),

        const SizedBox(height: 48),

        // Reproduction Graph / Timeline
        if (_reproductionGraph != null && _reproductionGraph!.isNotEmpty)
          _buildReproductionGraphUI(),
      ],
    );
  }

  Widget _buildReproductionGraphUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hub_outlined, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            Text(
              'SPREAD LIFECYCLE',
              style: GoogleFonts.robotoCondensed(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ..._reproductionGraph!.asMap().entries.map((entry) {
          final int idx = entry.key;
          final Map<String, dynamic> step = entry.value;
          final bool isLast = idx == _reproductionGraph!.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.black12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              step['time'] ?? '',
                              style: GoogleFonts.robotoCondensed(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              step['source'] ?? '',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['action'] ?? '',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (step['framing'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Framing: ${step['framing']}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnalysisSection({
    required String title,
    String? content,
    bool isList = false,
    List<String>? listItems,
    required IconData icon,
    Widget? customWidget,
    Color headerColor = Colors.black54,
    bool hasCitation = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: headerColor),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.robotoCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: headerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (customWidget != null) ...[
            customWidget,
            const SizedBox(height: 20),
          ],
          if (isList && listItems != null)
            ...listItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.roboto(fontSize: 16, height: 1.5, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  if (hasCitation) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _launchURL(widget.article.url),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.link_rounded, size: 12, color: Colors.black38),
                              const SizedBox(width: 4),
                              Text(
                                'Source',
                                style: GoogleFonts.robotoCondensed(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ))
          else if (content != null)
            Text(
              content,
              style: GoogleFonts.roboto(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildOriginalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.article.summary,
          style: GoogleFonts.roboto(fontSize: 18, height: 1.5),
        ),
        const SizedBox(height: 24),
        Text(
          widget.article.content,
          style: GoogleFonts.roboto(fontSize: 17, color: Colors.black54, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerBar(width: double.infinity, height: 20),
        const SizedBox(height: 12),
        _shimmerBar(width: double.infinity, height: 20),
        const SizedBox(height: 12),
        _shimmerBar(width: 200, height: 20),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              const SizedBox(height: 24),
              Text(
                'AI is verifying facts & analyzing bias...',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: Colors.black54),
          ),
          TextButton(
            onPressed: _performAnalysis,
            child: const Text('Try Again', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: widget.article.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(widget.article.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: const Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: widget.article.imageUrl == null
          ? const Icon(Icons.article_rounded, size: 40, color: Colors.black12)
          : null,
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: () => _launchURL(widget.article.url),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.open_in_new_rounded, size: 28, color: Colors.white),
      ),
    );
  }
}
