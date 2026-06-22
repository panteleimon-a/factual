import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/search_query.dart';
import '../services/database_service.dart';

class HistorySidebar extends StatelessWidget {
  final List<SearchQuery> history;
  final String? activeQuery;
  final Function(SearchQuery) onQueryTap;
  final VoidCallback onNewChatTap;
  final double width;
  final VoidCallback onHistoryUpdated;
  final bool showHomeButton;
  final VoidCallback? onHomeTap;

  const HistorySidebar({
    super.key,
    required this.history,
    this.activeQuery,
    required this.onQueryTap,
    required this.onNewChatTap,
    required this.width,
    required this.onHistoryUpdated,
    this.showHomeButton = false,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    final pinned = history.where((q) => q.isPinned).toList();
    final recent = history.where((q) => !q.isPinned).toList();

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        border: Border(right: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          if (showHomeButton)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 24),
              child: IconButton(
                icon: const Icon(Icons.home_outlined, size: 24, color: Colors.black),
                onPressed: onHomeTap,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(left: 24, bottom: 32),
              child: Icon(Icons.access_time_rounded, size: 24, color: Colors.black),
            ),

          // Pinned Section
          if (pinned.isNotEmpty) ...[
            _buildSectionHeader('Pinned'),
            ...pinned.map((q) => _buildSidebarItem(context, q)),
            const SizedBox(height: 32),
          ],

          const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 24, endIndent: 24),
          const SizedBox(height: 24),

          // New Chat Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              onTap: onNewChatTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      'New chat',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.mode_edit_outline_outlined, size: 16, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),

          // Recent Section
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Recent'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: recent.map((q) => _buildSidebarItem(context, q)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.robotoCondensed(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.black26,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, SearchQuery query) {
    final isActive = activeQuery == query.query;
    return InkWell(
      onTap: () => onQueryTap(query),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isActive ? Colors.black.withOpacity(0.05) : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  query.query,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? Colors.black : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    query.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 16,
                    color: query.isPinned ? Colors.black : Colors.black26,
                  ),
                  onPressed: () async {
                    final db = Provider.of<DatabaseService>(context, listen: false);
                    await db.togglePinQuery(query.id, !query.isPinned);
                    onHistoryUpdated();
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.black26),
                  onPressed: () async {
                    final db = Provider.of<DatabaseService>(context, listen: false);
                    await db.deleteSearchQuery(query.id);
                    onHistoryUpdated();
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
