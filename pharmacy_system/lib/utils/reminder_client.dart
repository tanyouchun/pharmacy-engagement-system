import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../viewmodels/reminder_viewmodel.dart';

class ReminderClient {
  static void showReminderForm(
    BuildContext context, {
    Reminder? reminder,
    String? initialMedicineName,
    String? initialFrequency,
  }) {
    final isEditing = reminder != null;

    final medicationController = TextEditingController(
      text: reminder?.medicationName ?? initialMedicineName ?? "",
    );

    TimeOfDay? selectedTime =
        reminder != null
            ? TimeOfDay(
              hour: reminder.scheduleTime.hour,
              minute: reminder.scheduleTime.minute,
            )
            : TimeOfDay.now();

    String frequency = reminder?.frequency ?? initialFrequency ?? "Once Daily";

    final reminderViewModel = Provider.of<ReminderViewModel>(
      context,
      listen: false,
    );

    final frequencies = [
      "Once Daily",
      "Twice Daily",
      "Three Times Daily",
      "Four Times Daily",
    ];

    showDialog(
      context: context,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );

              if (picked != null) {
                setState(() {
                  selectedTime = picked;
                });
              }
            }

            Future<void> save() async {
              if (medicationController.text.trim().isEmpty) {
                return;
              }

              final now = DateTime.now();

              final dateTime = DateTime(
                now.year,
                now.month,
                now.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              final reminderTimes = generateReminderTimes(
                selectedTime!,
                frequency,
              );

              if (!isEditing) {
                await reminderViewModel.createReminder(
                  Reminder(
                    reminderId: "",
                    userId: reminderViewModel.userId,
                    prescriptionId: "",
                    medicationName: medicationController.text,
                    scheduleTime: dateTime,
                    frequency: frequency,
                    reminderTimes: reminderTimes,
                  ),
                );
              } else {
                await reminderViewModel.updateReminder(
                  reminder!.copyWith(
                    medicationName: medicationController.text,
                    time: dateTime,
                    frequency: frequency,
                    reminderTimes: reminderTimes,
                  ),
                );
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,

              child: Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),

                      blurRadius: 20,

                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// HEADER
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(Icons.alarm, color: Colors.blue),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              isEditing ? "Edit Reminder" : "Create Reminder",

                              style: const TextStyle(
                                fontSize: 22,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// MEDICATION
                      _buildTextField(
                        controller: medicationController,

                        label: "Medication Name",

                        hint: "Enter medication name",

                        icon: Icons.medication_outlined,
                      ),

                      const SizedBox(height: 20),

                      /// TIME
                      const Text(
                        "Reminder Time",

                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 10),

                      InkWell(
                        onTap: pickTime,

                        borderRadius: BorderRadius.circular(18),

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,

                            vertical: 18,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  selectedTime!.format(context),

                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),

                              const Icon(Icons.keyboard_arrow_right_rounded),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// FREQUENCY
                      const Text(
                        "Frequency",

                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: frequency,

                            isExpanded: true,

                            items:
                                frequencies
                                    .map(
                                      (f) => DropdownMenuItem(
                                        value: f,

                                        child: Text(f),
                                      ),
                                    )
                                    .toList(),

                            onChanged: (value) {
                              setState(() {
                                frequency = value!;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      /// BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 56),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              child: const Text("Cancel"),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: save,

                              style: ElevatedButton.styleFrom(
                                elevation: 0,

                                backgroundColor: const Color(0xFF4FC3CF),

                                minimumSize: const Size(0, 56),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              child: Text(
                                isEditing ? "Update" : "Save",

                                style: const TextStyle(
                                  color: Colors.white,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
  }

  static Widget _buildTextField({
    required TextEditingController controller,

    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,

          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(icon),

            filled: true,

            fillColor: Colors.grey.shade100,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: const BorderSide(
                color: Color(0xFF4FC3CF),

                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static List<String> generateReminderTimes(
    TimeOfDay startTime,
    String frequency,
  ) {
    int timesPerDay = 1;

    switch (frequency.toLowerCase()) {
      case "twice daily":
        timesPerDay = 2;
        break;

      case "three times daily":
        timesPerDay = 3;
        break;

      case "four times daily":
        timesPerDay = 4;
        break;

      default:
        timesPerDay = 1;
    }

    final intervalHours = 24 ~/ timesPerDay;

    final times = <String>[];

    for (int i = 0; i < timesPerDay; i++) {
      final hour = (startTime.hour + (intervalHours * i)) % 24;

      final formatted =
          "${hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

      times.add(formatted);
    }

    return times;
  }

  static void showReminderFormFromPrescription(
    BuildContext context, {
    required String medicineName,
    required String frequency,
  }) {
    showReminderForm(
      context,
      initialMedicineName: medicineName,
      initialFrequency: frequency,
    );
  }
}
