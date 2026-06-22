import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class factualHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isHistoryPage;
  final VoidCallback? onHistoryTap;

  const factualHeader({
    super.key, 
    this.isHistoryPage = false,
    this.onHistoryTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;

    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 8 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Group: History (Show only on Main, or Back on History)
              SizedBox(
                width: 70, // Wider for text
                child: isHistoryPage 
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: onHistoryTap ?? () => context.pop(),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    )
                  : IconButton(
                      icon: const Icon(Icons.history_rounded, size: 28, color: Colors.black),
                      onPressed: onHistoryTap ?? () => context.push('/history'),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
              ),
              
              const Spacer(),
              
              // Center Group: Branding or Home Button
              Flexible(
                flex: 4,
                child: isHistoryPage
                  ? IconButton(
                      icon: const Icon(Icons.home_filled, size: 32, color: Colors.black),
                      onPressed: onHistoryTap ?? () => context.go('/'),
                    )
                  : GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text(
                        'factual',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: isSmallPhone ? 28 : 34,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ),
              
              const Spacer(),
              
              // Right Group: Icons
              SizedBox(
                width: 92,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 26),
                      onPressed: () => context.push('/notifications'),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pravatar.cc/150?u=factual_user'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
