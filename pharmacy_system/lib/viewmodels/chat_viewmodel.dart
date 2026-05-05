import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';
import '../services/chat_service.dart';
import '../constants/error_message.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Message> messages = [];
  String? errorMessage;
  StreamSubscription? _messageSubscription;

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
      log("${ErrorMessage.SEND_MESSAGE_ERROR}: $e");
      errorMessage = ErrorMessage.SEND_MESSAGE_ERROR;
      return;
    }
  }

  Future<void> editMessage(
    String chatId,
    String messageId,
    String newText,
  ) async {
    try {
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
    } catch (e) {
      log("${ErrorMessage.EDIT_MESSAGE_ERROR}: $e");
      errorMessage = ErrorMessage.EDIT_MESSAGE_ERROR;
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
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
    } catch (e) {
      log("${ErrorMessage.DELETE_MESSAGE_ERROR}: $e");
      errorMessage = ErrorMessage.DELETE_MESSAGE_ERROR;
      notifyListeners();
    }
  }

  void listenMessages(String chatId) {
    try {
      _messageSubscription?.cancel();

      _messageSubscription = _firestore
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
    } catch (e) {
      log("${ErrorMessage.LISTEN_MESSAGES_ERROR}: $e");
      errorMessage = ErrorMessage.LISTEN_MESSAGES_ERROR;
      notifyListeners();
    }
  }

  void disposeListener() {
    log("Disposing chat listener");
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }
}
