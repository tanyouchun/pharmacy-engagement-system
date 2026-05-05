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
      appBar: AppBar(title: const Text("Start Chat")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pharmacist_profiles')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pharmacists = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pharmacists.length,
            itemBuilder: (context, index) {
              final doc = pharmacists[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? "Pharmacist";
              final pharmacistId = doc.id;

              return ListTile(
                leading: const CircleAvatar(),
                title: Text(name),
                onTap: () async {
                  final chatViewModel = Provider.of<ChatViewModel>(
                    context,
                    listen: false,
                  );

                  final chatId = await chatViewModel.startChat(pharmacistId);

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatView(
                          chatId: chatId,
                          otherUserId: pharmacistId,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}