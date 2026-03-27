import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pharmacy_system/views/pharmacist/user_profile_details_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../views/user/pharmacist_profile_details_view.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  final String? otherUserId;

  const ChatView({super.key, required this.chatId, this.otherUserId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Start listening via ViewModel
    Future.microtask(() {
      final vm = Provider.of<ChatViewModel>(context, listen: false);
      vm.listenMessages(widget.chatId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),

            onPressed: () async {
              log("Other User ID: ${widget.otherUserId}");
              if (widget.otherUserId == null || widget.otherUserId!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not available")),
                );
                return;
              }

              final currentUser = FirebaseAuth.instance.currentUser!;

              // Fetch current user's role
              final doc =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .get();

              final role = doc.data()?['role'] ?? 'user';

              if (role == 'user') {
                // user → view pharmacist profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PharmacistProfileDetailsView(
                          pharmacistId: widget.otherUserId!,
                        ),
                  ),
                );
              } else {
                // pharmacist → view user profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            UserProfileDetailsView(userId: widget.otherUserId!),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, vm, _) {
                return ListView(
                  children:
                      vm.messages.map((msg) {
                        final isMe = msg.senderId == user.uid;

                        return GestureDetector(
                          onLongPress:
                              isMe
                                  ? () =>
                                      _showOptions(context, msg.messageId, msg.messageText)
                                  : null,
                          child: Align(
                            alignment:
                                isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.messageText,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  if (msg.isEdited)
                                    Text(
                                      "edited",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                        color:
                                            isMe
                                                ? Colors.white70
                                                : Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (controller.text.isEmpty) return;

                    final vm = Provider.of<ChatViewModel>(
                      context,
                      listen: false,
                    );

                    await vm.sendMessage(widget.chatId, controller.text);

                    controller.clear();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, String messageId, String text) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(messageId, text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete"),
              onTap: () async {
                Navigator.pop(context);

                final vm = Provider.of<ChatViewModel>(context, listen: false);

                await vm.deleteMessage(widget.chatId, messageId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String messageId, String oldText) {
    final editController = TextEditingController(text: oldText);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Message"),
          content: TextField(controller: editController),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final vm = Provider.of<ChatViewModel>(context, listen: false);

                await vm.editMessage(
                  widget.chatId,
                  messageId,
                  editController.text,
                );

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
