import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chatbot_viewmodel.dart';
import '../viewmodels/admin_config_viewmodel.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatBotViewModel = Provider.of<ChatBotViewModel>(context);

    final configViewModel = Provider.of<AdminManageConfigViewModel>(context);

    final isChatbotEnabled = configViewModel.isChatbotEnabled;

    return Scaffold(
      backgroundColor: const Color(0xFFDDF9FF),

      body: SafeArea(
        child: Column(
          children: [
            /// CHATBOT DISABLED MESSAGE
            if (!isChatbotEnabled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: const Text(
                  "Chatbot is currently unavailable.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chatBotViewModel.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatBotViewModel.messages[index];

                  bool isUser = msg["role"] == "user";

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,

                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),

                      padding: const EdgeInsets.all(12),

                      constraints: const BoxConstraints(maxWidth: 250),

                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.white,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        msg["content"]!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (chatBotViewModel.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),

            /// INPUT BAR
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),

                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,

                          enabled: isChatbotEnabled,

                          decoration: InputDecoration(
                            hintText:
                                isChatbotEnabled
                                    ? "Ask anything..."
                                    : "Chatbot unavailable",

                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.send),

                        onPressed:
                            isChatbotEnabled
                                ? () {
                                  if (controller.text.trim().isEmpty) {
                                    return;
                                  }

                                  chatBotViewModel.sendMessage(controller.text);

                                  controller.clear();
                                }
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
