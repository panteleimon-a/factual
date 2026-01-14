import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class factualHeader extends StatelessWidget implements PreferredSizeWidget {
  const factualHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased height

  @override
  Widget build(BuildContext context) {
    // Responsive sizing logic
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
              // Left Group: History
              SizedBox(
                width: 48,
                child: IconButton(
                  icon: const Icon(Icons.access_time_rounded, color: Colors.black, size: 26),
                  onPressed: () => context.push('/history'),
                  padding: EdgeInsets.zero,
                ),
              ),
              
              const Spacer(),
              
              // Center Group: Branding
              Flexible(
                flex: 4,
                child: GestureDetector(
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
                width: 80, // Space for two icons
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 26),
                    const SizedBox(width: 12),
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
