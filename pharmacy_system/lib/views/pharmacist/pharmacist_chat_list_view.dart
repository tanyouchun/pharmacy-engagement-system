import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat_view.dart';
import '../../utils/format_time.dart';

class PharmacistChatListView extends StatefulWidget {
  const PharmacistChatListView({super.key});

  @override
  State<PharmacistChatListView> createState() => _PharmacistChatListViewState();
}

class _PharmacistChatListViewState extends State<PharmacistChatListView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final pharmacist = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4FACFE), Color(0xFF00C6FB)],
              ),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Patient Messages",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Respond to patient conversations",

                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),

                /// SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),

                  child: TextField(
                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: "Search chats...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                      ),

                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.8),
                      ),

                      border: InputBorder.none,
                    ),

                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// CHAT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .where('participants', arrayContains: pharmacist.uid)
                      .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data!.docs;

                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ],
                          ),

                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          "No patient conversations",

                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Patient chats will appear here",

                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),

                  itemCount: chats.length,

                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    final data = chat.data() as Map<String, dynamic>;

                    final participants = List<String>.from(
                      data['participants'] ?? [],
                    );

                    final otherUserId = participants.firstWhere(
                      (id) => id != pharmacist.uid,
                    );

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('user_profiles')
                              .doc(otherUserId)
                              .get(),

                      builder: (context, userSnap) {
                        String name = "User";

                        if (userSnap.hasData && userSnap.data!.exists) {
                          final map =
                              userSnap.data!.data() as Map<String, dynamic>?;

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
                            String lastMessage = "No messages yet";

                            Timestamp? lastTimestamp;

                            if (msgSnap.hasData &&
                                msgSnap.data!.docs.isNotEmpty) {
                              final msg =
                                  msgSnap.data!.docs.first.data()
                                      as Map<String, dynamic>;

                              lastMessage =
                                  msg['messageText'] ?? msg['text'] ?? '';

                              lastTimestamp = msg['timestamp'] as Timestamp?;
                            }

                            final matchesSearch =
                                _searchQuery.isEmpty ||
                                name.toLowerCase().contains(_searchQuery);

                            if (!matchesSearch) {
                              return const SizedBox.shrink();
                            }

                            return StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(chat.id)
                                      .collection('messages')
                                      .where('isRead', isEqualTo: false)
                                      .snapshots(),
                              builder: (context, unreadSnap) {
                                final hasUnread =
                                    unreadSnap.hasData &&
                                    unreadSnap.data!.docs.any(
                                      (doc) =>
                                          (doc.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >)['senderId'] !=
                                          pharmacist.uid,
                                    );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),

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

                                    child: Padding(
                                      padding: const EdgeInsets.all(16),

                                      child: Row(
                                        children: [
                                          /// AVATAR
                                          Stack(
                                            children: [
                                              Container(
                                                height: 62,
                                                width: 62,

                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF4FACFE),
                                                          Color(0xFF00C6FB),
                                                        ],
                                                      ),

                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),

                                                child: Center(
                                                  child: Text(
                                                    name.isNotEmpty
                                                        ? name[0].toUpperCase()
                                                        : "U",

                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(width: 16),

                                          /// INFO
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

                                                const SizedBox(height: 6),

                                                Text(
                                                  lastMessage,

                                                  maxLines: 1,

                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,

                                                    fontSize: 13,

                                                    height: 1.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          /// TIME
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,

                                            children: [
                                              Text(
                                                FormatTime.formatTime(
                                                  lastTimestamp,
                                                ),

                                                style: TextStyle(
                                                  color: Colors.grey.shade500,

                                                  fontSize: 11,

                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              if (hasUnread)
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
