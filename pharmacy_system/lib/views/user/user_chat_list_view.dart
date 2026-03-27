import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat_view.dart';
import 'pharmacist_list_view.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: user.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                "No chats yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;

              final participants = List<String>.from(data['participants']);

              final otherUserId = participants.firstWhere(
                (id) => id != user.uid,
              );

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('pharmacist_profiles')
                        .doc(otherUserId)
                        .get(),
                builder: (context, userSnap) {
                  String name = "User";

                  if (userSnap.hasData && userSnap.data!.exists) {
                    final map = userSnap.data!.data() as Map<String, dynamic>?;
                    name = map?['name'] ?? "User";
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chat.id)
                            .collection('messages')
                            .orderBy('timestamp', descending: true)
                            .limit(1)
                            .snapshots(),
                    builder: (context, msgSnap) {
                      String lastMessage = '';
                      Timestamp? lastTimestamp;

                      if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
                        final msg =
                            msgSnap.data!.docs.first.data()
                                as Map<String, dynamic>;
                        lastMessage = (msg['text'] ?? '').toString();
                        lastTimestamp = msg['timestamp'] as Timestamp?;
                      } else {
                        lastMessage = (data['lastMessage'] ?? '').toString();
                        lastTimestamp = data['lastTimestamp'] as Timestamp?;
                      }

                      final matchesSearch =
                          _searchQuery.isEmpty ||
                          name.toLowerCase().contains(_searchQuery);

                      if (!matchesSearch) {
                        return const SizedBox.shrink();
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
                                builder:
                                    (_) => ChatView(
                                      chatId: chat.id,
                                      otherUserId: otherUserId,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9EEF0),
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
                                const CircleAvatar(radius: 26),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(lastTimestamp),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("New Chat"),
        icon: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PharmacistListView()),
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
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}";
    }
  }
}
