import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/reminder_viewmodel.dart';
import 'create_reminder_view.dart';
import 'chatbot_view.dart';

class ReminderHomeView extends StatefulWidget {
  final String? role;
  final VoidCallback? onOpenChatbot;
  const ReminderHomeView({super.key, this.role, this.onOpenChatbot});

  @override
  State<ReminderHomeView> createState() => _ReminderHomeViewState();
}

class _ReminderHomeViewState extends State<ReminderHomeView> {
  @override
  void initState() {
    super.initState();

    if (widget.role != 'pharmacist') {
      Future.microtask(
        () =>
            Provider.of<ReminderViewModel>(
              context,
              listen: false,
            ).fetchReminders(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ReminderViewModel>(context);
    final isPharmacist = widget.role == 'pharmacist';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                /// AI BANNER CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      /// 🤖 AI IMAGE
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),

                      const SizedBox(width: 15),

                      /// TEXT + BUTTON
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "AI Assistant",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            GestureDetector(
                              onTap: () {
                                widget.onOpenChatbot?.call();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Chat with AI",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //TODO insert avatar here if needed
                      /// USER AVATAR
                      // const CircleAvatar(
                      //   radius: 20,
                      //   backgroundImage: AssetImage(
                      //     "assets/avatar.png",
                      //   ), // replace if needed
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// TITLE BELOW
          isPharmacist
              ? const Text(
                "Pharmacist Home Page",
                style: TextStyle(color: Colors.black, fontSize: 18),
              )
              : const Text(
                "Medication Reminders",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),

          /// LIST
          Expanded(
            child:
                isPharmacist
                    /// 👇 PHARMACIST VIEW (AI-focused empty state)
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.smart_toy,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Use AI Assistant to help patients",
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () {
                              widget.onOpenChatbot?.call();
                            },
                            child: const Text("Open Chatbot"),
                          ),
                        ],
                      ),
                    )
                    /// 👇 PATIENT VIEW (normal reminders)
                    : vm.reminders.isEmpty
                    ? const Center(child: Text("No reminders yet"))
                    : ListView.builder(
                      itemCount: vm.reminders.length,
                      itemBuilder: (context, index) {
                        final r = vm.reminders[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(r.medicationName),
                            subtitle: Text(r.frequency),
                            trailing: Text(
                              "${r.time.hour}:${r.time.minute.toString().padLeft(2, '0')}",
                            ),
                            onTap: () => _showReminderDetails(context, r),
                            onLongPress: () => _confirmDelete(context, r.id),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      floatingActionButton:
          isPharmacist
              ? null
              : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateReminderView(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
    );
  }

  void _showReminderDetails(BuildContext context, reminder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.medicationName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text("Frequency: ${reminder.frequency}"),
              Text(
                "Time: ${reminder.time.hour}:${reminder.time.minute.toString().padLeft(2, '0')}",
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// EDIT
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToEdit(reminder);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                  ),

                  /// DELETE
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(context, reminder.id);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final vm = Provider.of<ReminderViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Reminder"),
            content: const Text(
              "Are you sure you want to delete this reminder?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await vm.deleteReminder(id);
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  void _goToEdit(reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateReminderView(reminder: reminder)),
    );
  }
}
