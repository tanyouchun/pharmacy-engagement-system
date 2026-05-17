import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/openai_service.dart';

class ChatBotViewModel extends ChangeNotifier {
  final OpenAIService _service = OpenAIService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  ChatBotViewModel() {
    _auth.authStateChanges().listen((user) async {
      messages.clear();

      if (user == null) {
        messages.add({
          "role": "assistant",
          "content": "Please log in to use the chatbot.",
        });
        notifyListeners();
        return;
      }

      await _loadChat();
    });
  }

  List<Map<String, String>> getOpenAIMessages() {
    return messages
        .where((m) => m["role"] == "user" || m["role"] == "assistant")
        .map((m) => {"role": m["role"]!, "content": m["content"]!})
        .toList();
  }

  Future<void> _loadChat() async {
    if (_uid == null) return;

    final snapshot =
        await _firestore
            .collection("users")
            .doc(_uid)
            .collection("chatbot_messages")
            .orderBy("timestamp")
            .get();

    messages =
        snapshot.docs.map((doc) {
          return {
            "role": doc["role"] as String,
            "content": doc["content"] as String,
          };
        }).toList();

    if (messages.isEmpty) {
      _addWelcomeMessage();
    }

    notifyListeners();
  }

  void _addWelcomeMessage() {
    messages.add({
      "role": "assistant",
      "content":
          "Hi! I’m your pharmacist assistant 💊.\n\n"
          "I can help with:\n"
          "• Medication usage\n"
          "• Side effects\n"
          "• Dosage guidance\n\n"
          "How can I help you today?",
    });
  }

  Future<void> _saveMessage(String role, String content) async {
    if (_uid == null) return;

    await _firestore
        .collection("users")
        .doc(_uid)
        .collection("chatbot_messages")
        .add({
          "role": role,
          "content": content,
          "timestamp": FieldValue.serverTimestamp(),
        });
  }

  Future<void> sendMessage(String userMessage) async {
    if (_uid == null) return;
    if (userMessage.trim().isEmpty) return;

    messages.add({"role": "user", "content": userMessage});
    await _saveMessage("user", userMessage);

    isLoading = true;
    notifyListeners();

    try {
      final openAIMessages = getOpenAIMessages();

      final reply = await _service.sendMessage(openAIMessages);

      messages.add({"role": "assistant", "content": reply});
      await _saveMessage("assistant", reply);
    } catch (e) {
      log("Error: $e");

      messages.add({
        "role": "assistant",
        "content": "Something went wrong. Please try again later.",
      });
    }

    isLoading = false;
    notifyListeners();
  }
}
