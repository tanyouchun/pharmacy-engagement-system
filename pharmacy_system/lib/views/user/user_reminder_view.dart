import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../viewmodels/reminder_viewmodel.dart';
import 'user_create_reminder_view.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/reminder.dart';

class ReminderHomeView extends StatefulWidget {
  final String? role;
  final VoidCallback? onOpenChatbot;
  const ReminderHomeView({super.key, this.role, this.onOpenChatbot});

  @override
  State<ReminderHomeView> createState() => _ReminderHomeViewState();
}

class _ReminderHomeViewState extends State<ReminderHomeView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.role != 'pharmacist' && widget.role != 'admin') {
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
    final reminderViewModel = Provider.of<ReminderViewModel>(context);
    final isPharmacist = widget.role == 'pharmacist';
    final isAdmin = widget.role == 'admin';
    final today = DateTime.now();

    return Scaffold(
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
                // AI BANNER CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // AI IMAGE
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

                      //TODO insert avatar here
                      /// USER AVATAR
                      // const CircleAvatar(
                      //   radius: 20,
                      //   backgroundImage: AssetImage(
                      //     "assets/avatar.png",
                      //   ),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //calender imported from table_calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            daysOfWeekHeight: 20,
            rowHeight: 40,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text("Today: ${today.day}/${today.month}/${today.year}"),
          const SizedBox(height: 20),

          // pharmacist no medication reminders, just AI banner
          isPharmacist
              ? const Text(
                "Pharmacist Home Page",
                style: TextStyle(color: Colors.black, fontSize: 18),
              )
              : isAdmin
              ? const Text(
                "Admin Homepage",
                style: TextStyle(color: Colors.black, fontSize: 18),
              )
              : const Text(
                "Medication Reminders",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),

          Expanded(
            child:
                (isPharmacist || isAdmin)
                    // PHARMACIST VIEW (AI-focused empty state)
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
                    // regular user view (medication reminders)
                    : reminderViewModel.reminders.isEmpty
                    ? const Center(child: Text("No reminders yet"))
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: reminderViewModel.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminderViewModel.reminders[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Slidable(
                            key: ValueKey(reminder.reminderId),

                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.5,

                              children: [
                                /// EDIT
                                SlidableAction(
                                  onPressed: (_) => _goToEdit(reminder),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                  borderRadius: BorderRadius.circular(16),
                                ),

                                /// DELETE
                                SlidableAction(
                                  onPressed:
                                      (_) => _confirmDelete(
                                        context,
                                        reminder.reminderId,
                                      ),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            ),

                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),

                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.medication,
                                    color: Colors.blue,
                                  ),
                                ),

                                title: Text(
                                  reminder.medicationName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(reminder.frequency),
                                ),

                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.access_time, size: 18),

                                    const SizedBox(height: 4),

                                    Text(
                                      "${reminder.scheduleTime.hour}:${reminder.scheduleTime.minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                onTap:
                                    () =>
                                        _showReminderDetails(context, reminder),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      floatingActionButton:
          (isPharmacist || isAdmin)
              ? null
              : FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateReminderView(),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF4FC3CF),
                foregroundColor: Colors.black,
                label: const Text("Add new reminder"),
                icon: const Icon(Icons.add),
              ),
    );
  }

  void _showReminderDetails(BuildContext context, Reminder reminder) {
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
                "Time: ${reminder.scheduleTime.hour}:${reminder.scheduleTime.minute.toString().padLeft(2, '0')}",
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
                      //TODO need to check reminderId?
                      _confirmDelete(context, reminder.reminderId);
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

  void _confirmDelete(BuildContext context, String reminderId) {
    final reminderViewModel = Provider.of<ReminderViewModel>(
      context,
      listen: false,
    );

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
                  await reminderViewModel.deleteReminder(reminderId);
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
