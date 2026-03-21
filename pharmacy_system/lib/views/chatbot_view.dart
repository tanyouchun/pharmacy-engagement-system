import 'package:flutter/material.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'AI Chatbot (coming soon)',
        textAlign: TextAlign.center,
      ),
    );
  }
}

