import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/repositories/chat_repository.dart';
import '../../app/repositories/user_repository.dart';
import '../../app/models/app_user.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class ChatScreen extends StatefulWidget {
  final String peerUserId;

  const ChatScreen({super.key, required this.peerUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _repo = ChatRepository();
  final _userRepo = UserRepository();
  late final Future<void> _chatReadyFuture;

  @override
  void initState() {
    super.initState();
    _chatReadyFuture = _ensureChat();
  }

  Future<void> _ensureChat() async {
    final me = FirebaseAuth.instance.currentUser?.uid ?? '';
    final peer = widget.peerUserId;
    if (me.isEmpty || peer.isEmpty) return;
    final chatId = _repo.chatIdForUsers(me, peer);
    await _repo.ensureChatExists(
      chatId: chatId,
      userA: me,
      userB: peer,
    );
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser?.uid ?? '';
    final peer = widget.peerUserId;

    if (me.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please login to chat')),
      );
    }

    final chatId = _repo.chatIdForUsers(me, peer);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<AppUser?>(
          future: _userRepo.getUser(peer),
          builder: (context, snap) {
            final u = snap.data;
            final name = (u?.displayName?.isNotEmpty == true)
                ? u!.displayName!
                : (u?.email.isNotEmpty == true ? u!.email : 'Chat');
            return Text(name, style: semiBoldStyle(fontSize: 18, color: Colors.black87));
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _chatReadyFuture,
        builder: (context, readySnap) {
          if (readySnap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (readySnap.hasError) {
            return Center(
              child: Text(
                'Could not start chat. Please try again.',
                style: regularStyle(fontSize: 14, color: ColorManager.darkBrown),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _repo.watchMessages(chatId: chatId),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load messages.',
                          style: regularStyle(fontSize: 14, color: ColorManager.darkBrown),
                        ),
                      );
                    }

                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data();
                        final senderId = (data['senderId'] ?? '').toString();
                        final text = (data['text'] ?? '').toString();
                        final isMe = senderId == me;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? ColorManager.brown : ColorManager.lighterBeige,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              text,
                              style: regularStyle(
                                fontSize: 14,
                                color: isMe ? Colors.white : ColorManager.darkBrown,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style:regularStyle(fontSize: 16, color: Colors.black),

                          controller: _ctrl,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () async {
                          final text = _ctrl.text;
                          _ctrl.clear();
                          await _repo.sendMessage(
                            chatId: chatId,
                            senderId: me,
                            receiverId: peer,
                            text: text,
                          );
                        },
                        icon: const Icon(Icons.send_rounded),
                        color: ColorManager.brown,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

