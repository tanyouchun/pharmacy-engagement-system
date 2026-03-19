import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat_view.dart';

class PharmacistChatListView extends StatelessWidget {
  const PharmacistChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: user.uid)
                // .orderBy('lastTimestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No messages yet"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data();

              final participants = List<String>.from(data['participants']);

              // 🔥 Get the OTHER user (not pharmacist)
              final otherUserId = participants.firstWhere(
                (id) => id != user.uid,
              );

              return FutureBuilder(
                future:
                    FirebaseFirestore.instance
                        .collection('user_profiles')
                        .doc(otherUserId)
                        .get(),
                builder: (context, userSnap) {
                  String name = "User";

                  if (userSnap.hasData && userSnap.data!.exists) {
                    name = userSnap.data!['name'] ?? "User";
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatView(chatId: chat.id),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 233, 238, 240),
                          borderRadius: BorderRadius.circular(16),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            // 👤 Avatar
                            const CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                "https://i.pravatar.cc/150",
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 📄 Name + Message
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    data['lastMessage'] ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),

                            // 🕒 Time
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTime(data['lastTimestamp']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // 🔥 UNREAD BADGE
                                StreamBuilder<QuerySnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('chats')
                                          .doc(chat.id)
                                          .collection('messages')
                                          .where('isRead', isEqualTo: false)
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return const SizedBox();

                                    final user =
                                        FirebaseAuth.instance.currentUser!;
                                    final unreadDocs = snapshot.data!.docs;

                                    final count =
                                        unreadDocs.where((doc) {
                                          return doc['senderId'] != user.uid;
                                        }).length;

                                    // ❌ hide everything if no unread
                                    if (count == 0) return const SizedBox();

                                    return Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$count",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      // today → show time
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      // older → show date
      return "${date.day}/${date.month}";
    }
  }
}
