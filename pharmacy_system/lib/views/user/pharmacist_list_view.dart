import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../viewmodels/chat_viewmodel.dart';
import '../chat_view.dart';

class PharmacistListView extends StatelessWidget {
  const PharmacistListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,

        title: const Text(
          "Start Chat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),

      body: Column(
        children: [
          /// TOP HEADER
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4FACFE), Color(0xFF00C6FB)],
              ),

              borderRadius: BorderRadius.circular(28),

              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  color: Colors.blue.withOpacity(0.18),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  height: 65,
                  width: 65,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: const Icon(
                    Icons.local_pharmacy_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Licensed Pharmacists",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Chat with professional pharmacists for medication guidance and assistance.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'pharmacist')
                      .where('approvalStatus', isEqualTo: 'approved')
                      .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pharmacists = snapshot.data!.docs;

                if (pharmacists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "No available pharmacists",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),

                  itemCount: pharmacists.length,

                  itemBuilder: (context, index) {
                    final userDoc = pharmacists[index];
                    final pharmacistId = userDoc.id;

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('pharmacist_profiles')
                              .doc(pharmacistId)
                              .get(),

                      builder: (context, profileSnapshot) {
                        if (!profileSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final profileData =
                            profileSnapshot.data!.data()
                                as Map<String, dynamic>?;

                        final name = profileData?['name'] ?? "Pharmacist";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(24),

                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                                color: Colors.black.withOpacity(0.04),
                              ),
                            ],
                          ),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),

                            onTap: () async {
                              final chatViewModel = Provider.of<ChatViewModel>(
                                context,
                                listen: false,
                              );

                              final chatId = await chatViewModel.startChat(
                                pharmacistId,
                              );

                              if (context.mounted) {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChatView(
                                          chatId: chatId,
                                          otherUserId: pharmacistId,
                                        ),
                                  ),
                                );
                              }
                            },

                            child: Padding(
                              padding: const EdgeInsets.all(18),

                              child: Row(
                                children: [
                                  /// AVATAR
                                  Container(
                                    height: 65,
                                    width: 65,

                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4FACFE),
                                          Color(0xFF00C6FB),
                                        ],
                                      ),

                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Center(
                                      child: Text(
                                        name.substring(0, 1).toUpperCase(),

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
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
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),

                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,

                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),

                                          child: Text(
                                            "Verified Pharmacist",

                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// ARROW
                                  Container(
                                    padding: const EdgeInsets.all(10),

                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,

                                      shape: BoxShape.circle,
                                    ),

                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
