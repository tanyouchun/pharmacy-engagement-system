import 'dart:developer';

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
    log("Sending user message from: ${user.uid}");

    try {
      final message = {
        'senderId': user.uid,
        'messageText': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isEdited': false,
        'isRead': false,
      };
      log("Message sent details: ${message.toString()}");

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message);
      log("Successfully sent message");

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error during sending message/connecting to firestore: $e");
    }
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

    await messageRef.update({'messageText': newText, 'isEdited': true});

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
