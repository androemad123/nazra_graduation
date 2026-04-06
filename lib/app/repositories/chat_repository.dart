import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_repository.dart';
import '../models/notification_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepo;

  ChatRepository({FirebaseFirestore? firestore, NotificationRepository? notificationRepo})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationRepo = notificationRepo ?? NotificationRepository();

  String chatIdForUsers(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  DocumentReference<Map<String, dynamic>> _chatRef(String chatId) {
    return _firestore.collection('chats').doc(chatId);
  }

  CollectionReference<Map<String, dynamic>> _messagesRef(String chatId) {
    return _chatRef(chatId).collection('messages');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages({
    required String chatId,
    int limit = 50,
  }) {
    return _messagesRef(chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserChats({required String userId}) {
    return _firestore.collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Future<void> ensureChatExists({
    required String chatId,
    required String userA,
    required String userB,
  }) async {
    // Use merge set directly to avoid requiring a pre-read permission.
    await _chatRef(chatId).set({
      'participants': [userA, userB],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastSenderId': null,
    }, SetOptions(merge: true));
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await ensureChatExists(chatId: chatId, userA: senderId, userB: receiverId);

    final msgRef = _messagesRef(chatId).doc();
    await msgRef.set({
      'id': msgRef.id,
      'senderId': senderId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _chatRef(chatId).set({
      'participants': [senderId, receiverId],
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': trimmed,
      'lastSenderId': senderId,
    }, SetOptions(merge: true));

    await _notificationRepo.sendNotification(
      recipientId: receiverId,
      title: 'New Message',
      body: trimmed,
      type: NotificationType.chatMessage,
      relatedId: senderId,
    );
  }
}

