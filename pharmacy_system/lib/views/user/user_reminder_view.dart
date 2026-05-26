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

    return Scaffold(
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
                Text(
                  "Hello 👋",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  isAdmin
                      ? "Admin Dashboard"
                      : isPharmacist
                      ? "Pharmacist Dashboard"
                      : "Home Page",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                /// AI CARD
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),

                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "AI Assistant",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              "Ask medicine-related questions.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(height: 10),

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
                                  borderRadius: BorderRadius.circular(30),
                                ),

                                child: const Text(
                                  "Chat with AI",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),

              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.week,

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),

                daysOfWeekHeight: 20,
                rowHeight: 45,

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },

                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    shape: BoxShape.circle,
                  ),

                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF3D5CFF),
                    shape: BoxShape.circle,
                  ),

                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

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
                        final reminders = [...reminderViewModel.reminders];

                        reminders.sort(
                          (a, b) => a.scheduleTime.compareTo(b.scheduleTime),
                        );

                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),

                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),

                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4FACFE),
                                          Color(0xFF00C6FB),
                                        ],
                                      ),

                                      borderRadius: BorderRadius.circular(14),
                                    ),

                                    child: const Icon(
                                      Icons.alarm_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        const Text(
                                          "Medication Reminders",

                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          "Stay consistent with your medication schedule.",

                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(18),
                                    ),

                                    child: Text(
                                      "${reminders.length}",

                                      style: const TextStyle(
                                        color: Color(0xFF4FACFE),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            ...reminders.map((reminder) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),

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
                                        borderRadius: BorderRadius.circular(16),
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
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ],
                                  ),

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),

                                    onTap:
                                        () => _showReminderDetails(
                                          context,
                                          reminder,
                                        ),

                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),

                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),

                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                            color: Colors.black.withOpacity(
                                              0.04,
                                            ),
                                          ),
                                        ],
                                      ),

                                      child: Row(
                                        children: [
                                          /// ICON
                                          Container(
                                            padding: const EdgeInsets.all(10),

                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF4FACFE),
                                                  Color(0xFF00C6FB),
                                                ],
                                              ),

                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),

                                            child: const Icon(
                                              Icons.medication_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          /// CONTENT
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,

                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        reminder.medicationName,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,

                                                        style: const TextStyle(
                                                          fontSize: 14.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),

                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),

                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withOpacity(0.08),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),

                                                      child: Text(
                                                        reminder.frequency,

                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF4FACFE,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 10.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 8),

                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,

                                                  children:
                                                      reminder.reminderTimes.map((
                                                        time,
                                                      ) {
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 5,
                                                              ),

                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade100,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),

                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,

                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .access_time,
                                                                size: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),

                                                              const SizedBox(
                                                                width: 4,
                                                              ),

                                                              Text(
                                                                time,

                                                                style: const TextStyle(
                                                                  fontSize:
                                                                      10.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.grey.shade400,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.85,

          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),

              child: SingleChildScrollView(
                controller: scrollController,

                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// TOP DRAG HANDLE
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    /// TITLE
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.medication,
                            color: Colors.blue,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            reminder.medicationName,

                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// FREQUENCY CHIP
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons.repeat,
                            size: 18,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            reminder.frequency,

                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// REMINDER TIMES CARD
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: Colors.black87,
                              ),

                              SizedBox(width: 8),

                              Text(
                                "Reminder Times",

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          ...reminder.reminderTimes.map((time) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),

                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                    color: Colors.black.withOpacity(0.03),
                                  ),
                                ],
                              ),

                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),

                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),

                                    child: const Icon(
                                      Icons.alarm,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Text(
                                    time,

                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// INFO CARD
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.08),
                            Colors.cyan.withOpacity(0.08),
                          ],
                        ),

                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              "Make sure to take your medication on time according to the reminder schedule.",

                              style: TextStyle(
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
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
}
