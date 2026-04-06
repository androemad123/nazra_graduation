import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/models/app_user.dart';
import '../../app/repositories/chat_repository.dart';
import '../../app/repositories/user_repository.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'chat_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final _chatRepo = ChatRepository();
  final _userRepo = UserRepository();
  final _me = FirebaseAuth.instance.currentUser?.uid ?? '';

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, h:mm a').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_me.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Community Chats')),
        body: const Center(child: Text('Please login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Chats'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _chatRepo.watchUserChats(userId: _me),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Failed to load chats.',
                style: regularStyle(fontSize: 14, color: ColorManager.darkBrown),
              ),
            );
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No active chats'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: docs.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final participants = List<String>.from(data['participants'] ?? []);
              final peerId = participants.firstWhere((id) => id != _me, orElse: () => '');
              final lastMessage = (data['lastMessage'] ?? '').toString();
              final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              
              if (peerId.isEmpty) return const SizedBox.shrink();

              return FutureBuilder<AppUser?>(
                future: _userRepo.getUser(peerId),
                builder: (context, userSnap) {
                  final u = userSnap.data;
                  final name = (u?.displayName?.isNotEmpty == true)
                      ? u!.displayName!
                      : (u?.email.isNotEmpty == true ? u!.email : 'Unknown User');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ColorManager.brown.withOpacity(0.1),
                      child: const Icon(Icons.person, color: ColorManager.brown),
                    ),
                    title: Text(
                      name,
                      style: semiBoldStyle(fontSize: 16, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: regularStyle(fontSize: 14, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatDate(updatedAt),
                      style: regularStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(peerUserId: peerId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
