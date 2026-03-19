import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/pharmacist_list_viewmodel.dart';
import 'chat_view.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<PharmacistViewModel>(
            context,
            listen: false,
          ).loadPharmacists(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PharmacistViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // 🔍 SEARCH BAR
            TextField(
              onChanged: vm.search,
              decoration: InputDecoration(
                hintText: "Search pharmacist...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📋 LIST
            Expanded(
              child: ListView.builder(
                itemCount: vm.filtered.length,
                itemBuilder: (context, index) {
                  final p = vm.filtered[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150",
                        ),
                      ),
                      title: Text(p.name),
                      subtitle: Text("Pharmacist\n${p.pharmacyName}"),
                      trailing: const Icon(Icons.chat_bubble_outline),

                      // 👉 OPEN CHAT
                      onTap: () async {
                        final chatVM = Provider.of<ChatViewModel>(
                          context,
                          listen: false,
                        );

                        final chatId = await chatVM.startChat(p.id);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatView(chatId: chatId),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
