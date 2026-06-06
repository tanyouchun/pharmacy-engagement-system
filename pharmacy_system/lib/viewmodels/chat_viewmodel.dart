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
  bool showAIHelper = false;
  bool isPharmacist = false;

  final ChatService _chatService = ChatService();

  Future<String> startChat(String pharmacistId) async {
    return await _chatService.createOrGetChat(pharmacistId);
  }

  String get chatSubtitle {
    return isPharmacist ? "" : "Healthcare Consultation";
  }

  Future<void> checkLastReply({
    required String chatId,
    required String currentUserId,
  }) async {
    if (isPharmacist) {
      showAIHelper = false;
      notifyListeners();
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return;

    final data = snapshot.docs.first.data();

    final senderId = data['senderId'];
    final timestamp = data['timestamp'] as Timestamp?;

    if (timestamp == null) return;

    final diff = DateTime.now().difference(timestamp.toDate());

    showAIHelper = (senderId == currentUserId && diff.inSeconds >= 5);

    notifyListeners();
  }

  Future<void> loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    final role = doc.data()?['role'] ?? 'user';

    isPharmacist = role == 'pharmacist';
    notifyListeners();
  }

  String otherUserName = "User";

  Future<void> loadOtherUser(String? otherUserId) async {
    if (otherUserId == null) return;

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('user_profiles')
              .doc(otherUserId)
              .get();

      if (userDoc.exists) {
        otherUserName = userDoc.data()?['name'] ?? "User";
        notifyListeners();
        return;
      }

      final pharmacistDoc =
          await FirebaseFirestore.instance
              .collection('pharmacist_profiles')
              .doc(otherUserId)
              .get();

      if (pharmacistDoc.exists) {
        otherUserName = pharmacistDoc.data()?['name'] ?? "Pharmacist";
        notifyListeners();
        return;
      }

      otherUserName = "User";
      notifyListeners();
    } catch (e) {
      log("LOAD OTHER USER ERROR: $e");
    }
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

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot =
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        if (doc.data()['senderId'] != user.uid) {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();
    } catch (e) {
      log('MARK_MESSAGES_READ_ERROR: $e');
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
