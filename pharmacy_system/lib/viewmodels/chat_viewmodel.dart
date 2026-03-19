import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Message> messages = [];

  final ChatService _chatService = ChatService();

  Future<String> startChat(String pharmacistId) async {
    return await _chatService.createOrGetChat(pharmacistId);
  }

  Future<void> sendMessage(String chatId, String text) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final message = {
      'senderId': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'edited': false,
      'isRead': false,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editMessage(
    String chatId,
    String messageId,
    String newText,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final doc = await messageRef.get();

    // 🔒 only allow editing own message
    if (doc['senderId'] != user.uid) return;

    await messageRef.update({'text': newText, 'edited': true});

    // optional: update last message if needed
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': newText,
    });
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final doc = await messageRef.get();

    // 🔒 only allow deleting own message
    if (doc['senderId'] != user.uid) return;

    await messageRef.delete();
  }

  // 🔥 Listen to messages (REAL-TIME)
  void listenMessages(String chatId) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
          messages =
              snapshot.docs
                  .map((doc) => Message.fromMap(doc.id, doc.data()))
                  .toList();

          notifyListeners();
        });
  }
}
