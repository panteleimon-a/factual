import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/factual_header.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  // Mock data for blocked users
  final List<Map<String, String>> _blockedUsers = [
    {'name': 'Alex Johnson', 'username': '@alexj', 'avatar': 'https://i.pravatar.cc/150?u=1'},
    {'name': 'Sarah Smith', 'username': '@sarahs', 'avatar': 'https://i.pravatar.cc/150?u=2'},
    {'name': 'Mike Ross', 'username': '@miker', 'avatar': 'https://i.pravatar.cc/150?u=3'},
  ];

  void _unblockUser(int index) {
    setState(() {
      _blockedUsers.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User unblocked')),
    );
  }

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
                    'Blocked Users',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Managing these users prevents them from interacting with your published prompts or seeing your activity.',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: _blockedUsers.isEmpty
                  ? Center(
                      child: Text(
                        'No blocked users',
                        style: GoogleFonts.roboto(color: Colors.black26),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _blockedUsers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      itemBuilder: (context, index) {
                        final user = _blockedUsers[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['avatar']!),
                          ),
                          title: Text(
                            user['name']!,
                            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            user['username']!,
                            style: GoogleFonts.roboto(color: Colors.black45, fontSize: 13),
                          ),
                          trailing: TextButton(
                            onPressed: () => _unblockUser(index),
                            child: Text(
                              'Unblock',
                              style: GoogleFonts.roboto(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
