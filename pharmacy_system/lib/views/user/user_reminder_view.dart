import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../viewmodels/reminder_viewmodel.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/reminder.dart';
import '../../utils/reminder_client.dart';

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
                    : Builder(
                      builder: (context) {
                        final groupedReminders = <String, List<Reminder>>{};

                        for (var reminder in reminderViewModel.reminders) {
                          final period = getReminderPeriod(
                            reminder.scheduleTime,
                          );

                          groupedReminders.putIfAbsent(period, () => []);
                          groupedReminders[period]!.add(reminder);
                        }

                        return ListView(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 100,
                          ),

                          children:
                              groupedReminders.entries.map((entry) {
                                final sectionTitle = entry.key;
                                final reminders = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 12,
                                        bottom: 10,
                                      ),

                                      child: Text(
                                        sectionTitle,

                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    ...reminders.map((reminder) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),

                                        child: Slidable(
                                          key: ValueKey(reminder.reminderId),

                                          endActionPane: ActionPane(
                                            motion: const DrawerMotion(),
                                            extentRatio: 0.5,

                                            children: [
                                              SlidableAction(
                                                onPressed: (_) {
                                                  ReminderClient.showReminderForm(
                                                    context,
                                                    reminder: reminder,
                                                  );
                                                },
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                icon: Icons.edit,
                                                label: 'Edit',
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),

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
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ],
                                          ),

                                          child: Card(
                                            elevation: 2,
                                            color: const Color(0xFFEAF4FF),

                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),

                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),

                                              leading: Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),

                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
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

                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 4,
                                                          bottom: 6,
                                                        ),

                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),

                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withOpacity(0.1),

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),

                                                    child: Text(
                                                      reminder.frequency,

                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(height: 4),

                                                  Builder(
                                                    builder: (_) {
                                                      final times =
                                                          reminder
                                                              .reminderTimes;

                                                      List<List<String>>
                                                      chunks = [];
                                                      for (
                                                        int i = 0;
                                                        i < times.length;
                                                        i += 2
                                                      ) {
                                                        chunks.add(
                                                          times.sublist(
                                                            i,
                                                            i + 2 > times.length
                                                                ? times.length
                                                                : i + 2,
                                                          ),
                                                        );
                                                      }

                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children:
                                                            chunks.map((chunk) {
                                                              return Text(
                                                                chunk.join(
                                                                  " • ",
                                                                ),
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 11,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              );
                                                            }).toList(),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),

                                              onTap:
                                                  () => _showReminderDetails(
                                                    context,
                                                    reminder,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }).toList(),
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
                  ReminderClient.showReminderForm(context);
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
              const SizedBox(height: 8),

              const Text(
                "Reminder Times:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    reminder.reminderTimes.map((time) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.blue,
                            ),

                            const SizedBox(width: 6),

                            Text(time),
                          ],
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),
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

  String getReminderPeriod(DateTime time) {
    final hour = time.hour;

    if (hour >= 5 && hour < 12) {
      return "Morning ☀️";
    } else if (hour >= 12 && hour < 18) {
      return "Afternoon 🌤️";
    } else {
      return "Night 🌙";
    }
  }
}
