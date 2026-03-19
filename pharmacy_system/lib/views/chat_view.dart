import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatView extends StatefulWidget {
  final String chatId;

  const ChatView({super.key, required this.chatId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          // MESSAGES
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();

                final docs = snapshot.data!.docs;
                return ListView(
                  children:
                      docs.map((doc) {
                        final data = doc.data();
                        final isEdited = data['isEdited'] ?? false;
                        final isMe = data['senderId'] == user.uid;

                        return GestureDetector(
                          onLongPress:
                              isMe
                                  ? () {
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
                                                _showEditDialog(
                                                  doc.id,
                                                  data['text'],
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.delete),
                                              title: const Text("Delete"),
                                              onTap: () async {
                                                Navigator.pop(context);

                                                await FirebaseFirestore.instance
                                                    .collection('chats')
                                                    .doc(widget.chatId)
                                                    .collection('messages')
                                                    .doc(doc.id)
                                                    .delete();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
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
                                    data['text'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  if (isEdited)
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

          // ✏️ INPUT
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Message..."),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  if (controller.text.isEmpty) return;

                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .add({
                        'text': controller.text,
                        'senderId': user.uid,
                        'timestamp': FieldValue.serverTimestamp(),
                        'isEdited': false,
                        'isRead': false,
                      });

                  controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
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
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .doc(messageId)
                    .update({'text': editController.text, 'isEdited': true});

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _markMessagesAsRead() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) async {
          for (var doc in snapshot.docs) {
            if (doc['senderId'] != user.uid) {
              await doc.reference.update({'isRead': true});
            }
          }
        });
  }
}
