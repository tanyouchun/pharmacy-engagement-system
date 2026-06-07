import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../services/openai_service.dart';

class ChatBotViewModel extends ChangeNotifier {
  final OpenAIService _service = OpenAIService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  StreamSubscription<User?>? _authSub;

  List<ChatMessage> messages = [];
  bool isLoading = false;

  ChatBotViewModel() {
    _authSub = _auth.authStateChanges().listen((user) async {
      messages.clear();

      if (user == null) {
        messages.add(const ChatMessage(
          role: ChatRole.assistant,
          content: "Please log in to use the chatbot.",
        ));

        notifyListeners();
        return;
      }

      await _loadChat();
      notifyListeners();
    });
  }

  List<Map<String, String>> getOpenAIMessages() {
    return messages
        .where((m) => m.role == ChatRole.user || m.role == ChatRole.assistant)
        .map((m) => {"role": m.role.value, "content": m.content})
        .toList();
  }

  Future<void> _loadChat() async {
    if (_uid == null) return;

    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(_uid)
          .collection("chatbot_messages")
          .orderBy("timestamp")
          .get();

      messages = snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log("Error loading chatbot chat: $e");
      messages = [];
    }

    if (messages.isEmpty) {
      _addWelcomeMessage();
    }

    notifyListeners();
  }

  void _addWelcomeMessage() {
    messages.add(const ChatMessage(
      role: ChatRole.assistant,
      content:
          "Hi! I’m your pharmacist assistant 💊.\n\n"
          "I can help with:\n"
          "• Medication usage\n"
          "• Side effects\n"
          "• Dosage guidance\n\n"
          "How can I help you today?",
    ));
  }

  Future<void> _saveMessage(String role, String content) async {
    if (_uid == null) return;

    try {
      await _firestore
          .collection("users")
          .doc(_uid)
          .collection("chatbot_messages")
          .add({
            "role": role,
            "content": content,
            "timestamp": FieldValue.serverTimestamp(),
          });
    } catch (e) {
      log("Error saving chatbot message: $e");
    }
  }

  Future<void> sendMessage(String userMessage) async {
    if (_uid == null) return;
    if (userMessage.trim().isEmpty) return;

    messages.add(ChatMessage(role: ChatRole.user, content: userMessage));
    await _saveMessage("user", userMessage);

    isLoading = true;
    notifyListeners();

    try {
      final openAIMessages = getOpenAIMessages();

      final reply = await _service.sendMessage(
        messages: openAIMessages,
        promptKey: "chatbot_prompt",
      );

      messages.add(ChatMessage(role: ChatRole.assistant, content: reply));
      await _saveMessage("assistant", reply);
    } catch (e) {
      log("Error: $e");

      messages.add(const ChatMessage(
        role: ChatRole.assistant,
        content: "Something went wrong. Please try again later.",
      ));
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
