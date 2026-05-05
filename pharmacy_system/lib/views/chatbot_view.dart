import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chatbot_viewmodel.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFDDF9FF), // light blue background

      body: SafeArea(
        child: Column(
          children: [
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
                          decoration: const InputDecoration(
                            hintText: "Ask anything...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (controller.text.trim().isEmpty) return;

                          chatBotViewModel.sendMessage(controller.text);
                          controller.clear();
                        },
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
