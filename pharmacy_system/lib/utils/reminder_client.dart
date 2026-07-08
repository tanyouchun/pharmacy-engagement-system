import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../viewmodels/reminder_viewmodel.dart';
import '../viewmodels/prescription_viewmodel.dart';
import '../models/prescription.dart';

class ReminderClient {
  static Future<void> showReminderForm(
    BuildContext context, {
    Reminder? reminder,
    String? initialMedicationName,
    String? initialStrength,
    String? initialDose,
    String? initialFrequency,
    String? initialPrescriptionId,
    int? initialDuration,
  }) async {
    final isEditing = reminder != null;
    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );

    await prescriptionViewModel.loadPrescriptions();

    if (!context.mounted) {
      return;
    }

    String? prescriptionError;

    final medicationController = TextEditingController(
      text: reminder?.medicationName ?? initialMedicationName ?? "",
    );

    String strength = reminder?.strength ?? initialStrength ?? "100mg";
    String dose = reminder?.dose ?? initialDose ?? "1 pill";

    String durationOption =
        [
              "1",
              "3",
              "5",
              "7",
              "14",
              "30",
            ].contains((reminder?.duration ?? initialDuration ?? 3).toString())
            ? (reminder?.duration ?? initialDuration ?? 3).toString()
            : "other";

    final durationController = TextEditingController(
      text: (reminder?.duration ?? initialDuration ?? 3).toString(),
    );

    final prescriptionId =
        reminder?.prescriptionId ?? initialPrescriptionId ?? "";

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
    Prescription? selectedPrescription;

    if (prescriptionId.isNotEmpty) {
      try {
        selectedPrescription = prescriptionViewModel.prescriptions.firstWhere(
          (p) => p.prescriptionId == prescriptionId,
        );
      } catch (_) {
        selectedPrescription = null;
      }
    }

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
              final error = await reminderViewModel.saveReminder(
                isEditing: isEditing,
                existingReminder: reminder,
                selectedPrescription: selectedPrescription,
                selectedTime: selectedTime!,
                frequency: frequency,
                medicationName: medicationController.text,
                strength: strength,
                dose: dose,
                durationText: durationController.text,
                durationOption: durationOption,
              );

              if (error != null) {
                setState(() {
                  prescriptionError = error;
                });
                return;
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
                      const Text(
                        "Prescription",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Prescription>(
                            value: selectedPrescription,
                            isExpanded: true,
                            hint: const Text("Select Prescription"),
                            items:
                                prescriptionViewModel.prescriptions.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      "${p.medicationName} (${p.strength})",
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPrescription = value;

                                prescriptionError = null;

                                medicationController.text =
                                    value?.medicationName ?? "";

                                strength = value?.strength ?? "";

                                dose = value?.dose ?? "";

                                frequency = value?.frequency ?? "Once Daily";
                              });
                            },
                          ),
                        ),
                      ),
                      if (prescriptionError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          prescriptionError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],

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

                      /// STRENGTH
                      // const Text(
                      //   "Strength",

                      //   style: TextStyle(fontWeight: FontWeight.w600),
                      // ),
                      const Text(
                        "Strength",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
                            value: strength,
                            isExpanded: true,
                            items:
                                ["100mg", "250mg", "500mg", "5ml", "10ml"]
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                strength = value!;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// DOSE
                      // const Text(
                      //   "Dose",

                      //   style: TextStyle(fontWeight: FontWeight.w600),
                      // ),
                      const Text(
                        "Dose",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
                            value: dose,
                            isExpanded: true,
                            items:
                                [
                                      "1 pill",
                                      "2 pills",
                                      "1 tablet",
                                      "2 tablets",
                                      "1 teaspoon",
                                    ]
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                dose = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Duration",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
                            value: durationOption,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: "1",
                                child: Text("1 day"),
                              ),
                              DropdownMenuItem(
                                value: "2",
                                child: Text("2 days"),
                              ),
                              DropdownMenuItem(
                                value: "3",
                                child: Text("3 days"),
                              ),
                              DropdownMenuItem(
                                value: "4",
                                child: Text("4 days"),
                              ),
                              DropdownMenuItem(
                                value: "5",
                                child: Text("5 days"),
                              ),
                              DropdownMenuItem(
                                value: "7",
                                child: Text("7 days"),
                              ),
                              DropdownMenuItem(
                                value: "14",
                                child: Text("14 days"),
                              ),
                              DropdownMenuItem(
                                value: "30",
                                child: Text("30 days"),
                              ),
                              DropdownMenuItem(
                                value: "other",
                                child: Text("Other"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                durationOption = value!;
                              });
                            },
                          ),
                        ),
                      ),

                      if (durationOption == "other") ...[
                        const SizedBox(height: 12),

                        TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter duration in days",
                            prefixIcon: const Icon(Icons.calendar_today),
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

  static Future<void> showReminderFormFromPrescription(
    BuildContext context, {
    required String prescriptionId,
    required String medicationName,
    String? strength,
    String? dose,
    required String frequency,
    required int duration,
  }) async {
    await showReminderForm(
      context,
      initialPrescriptionId: prescriptionId,
      initialMedicationName: medicationName,
      initialStrength: strength,
      initialDose: dose,
      initialFrequency: frequency,
      initialDuration: duration,
    );
  }
}
