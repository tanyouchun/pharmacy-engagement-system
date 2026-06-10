import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pharmacy_system/views/pharmacist/user_profile_details_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../views/user/pharmacist_profile_details_view.dart';
import '../viewmodels/chat_viewmodel.dart';
import 'home_page.dart';

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

    Future.microtask(() async {
      final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

      chatViewModel.listenMessages(widget.chatId);

      await chatViewModel.loadUserRole();
      await chatViewModel.loadOtherUser(widget.otherUserId);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await chatViewModel.checkLastReply(
          chatId: widget.chatId,
          currentUserId: user.uid,
        );
        await chatViewModel.markMessagesAsRead(widget.chatId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Consumer<ChatViewModel>(
          builder: (context, chatViewModel, _) {
            return Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF4FC3CF),
                      child: Text(
                        chatViewModel.otherUserName.isNotEmpty
                            ? chatViewModel.otherUserName[0]
                            : "P",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Positioned(
                    //   bottom: 2,
                    //   right: 2,
                    //   child: Container(
                    //     width: 12,
                    //     height: 12,
                    //     decoration: BoxDecoration(
                    //       color: Colors.green,
                    //       borderRadius: BorderRadius.circular(20),
                    //       border: Border.all(color: Colors.white, width: 2),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatViewModel.otherUserName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (chatViewModel.chatSubtitle.isNotEmpty)
                      Text(
                        chatViewModel.chatSubtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () async {
              log("Other User ID: ${widget.otherUserId}");

              if (widget.otherUserId == null || widget.otherUserId!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not available")),
                );
                return;
              }

              final currentUser = FirebaseAuth.instance.currentUser!;
              final doc =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .get();

              final role = doc.data()?['role'] ?? 'user';

              if (role == 'user') {
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
          Consumer<ChatViewModel>(
            builder: (context, chatViewModel, _) {
              if (!chatViewModel.isPharmacist && chatViewModel.showAIHelper) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Need Immediate Help?",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Pharmacist response is taking longer than expected. You can ask the AI assistant for quick guidance.",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(initialIndex: 2),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Ask AI"),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          /// CHAT MESSAGES (UNCHANGED)
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, chatViewModel, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  itemCount: chatViewModel.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatViewModel.messages[index];
                    final isMe =
                        msg.senderId == FirebaseAuth.instance.currentUser!.uid;

                    return GestureDetector(
                      onLongPress:
                          isMe
                              ? () => _showOptions(
                                context,
                                msg.messageId,
                                msg.messageText,
                                msg.timestamp,
                              )
                              : null,
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMe ? const Color(0xFF4FC3CF) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.messageText,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (msg.isEdited)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'edited',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          isMe ? Colors.white70 : Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// INPUT (UNCHANGED)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (controller.text.trim().isEmpty) return;

                      final chatViewModel = Provider.of<ChatViewModel>(
                        context,
                        listen: false,
                      );

                      await chatViewModel.sendMessage(
                        widget.chatId,
                        controller.text.trim(),
                      );

                      controller.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4FC3CF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(
    BuildContext context,
    String messageId,
    String text,
    DateTime timestamp,
  ) {
    final now = DateTime.now();
    final differenceInMinutes = now.difference(timestamp).inMinutes;
    final canEditDelete = differenceInMinutes <= 30;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Message Options",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              if (canEditDelete)
                /// EDIT BUTTON
                _actionTile(
                  icon: Icons.edit_rounded,
                  title: "Edit Message",
                  subtitle: "Modify your message",
                  color: const Color(0xFF4FC3CF),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(messageId, text);
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cannot Edit",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              "Messages can only be edited within 30 minutes",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (canEditDelete)
                const SizedBox(height: 12)
              else
                const SizedBox(height: 12),

              if (canEditDelete)
                /// DELETE BUTTON
                _actionTile(
                  icon: Icons.delete_rounded,
                  title: "Delete Message",
                  subtitle: "Remove this message permanently",
                  color: Colors.redAccent,
                  onTap: () async {
                    Navigator.pop(context);

                    final chatViewModel = Provider.of<ChatViewModel>(
                      context,
                      listen: false,
                    );

                    await chatViewModel.deleteMessage(widget.chatId, messageId);
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cannot Delete",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              "Messages can only be deleted within 30 minutes",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String messageId, String oldText) {
    final editController = TextEditingController(text: oldText);

    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text("Edit Message"),

          content: TextField(controller: editController, maxLines: 3),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final chatViewModel = Provider.of<ChatViewModel>(
                  context,
                  listen: false,
                );

                await chatViewModel.editMessage(
                  widget.chatId,
                  messageId,
                  editController.text,
                );

                Navigator.pop(context);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3CF),
              ),

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
