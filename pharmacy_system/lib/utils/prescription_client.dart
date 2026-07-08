import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prescription.dart';
import '../viewmodels/prescription_viewmodel.dart';

class PrescriptionClient {
  static void showAddPrescription({
    required BuildContext context,
    String? userId,
  }) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    String? medicationNameError;

    String frequency = "Once Daily";
    String strength = "100mg";
    String dose = "1 pill";
    String durationOption = "3";
    final durationController = TextEditingController();
    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
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

                            child: const Icon(
                              Icons.medication,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Text(
                              "Add Prescription",

                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// MEDICINE NAME
                      _buildTextField(
                        controller: nameController,

                        label: "Medicine Name",

                        hint: "Enter medicine name",

                        icon: Icons.local_pharmacy_outlined,
                        errorText: medicationNameError,
                      ),

                      const SizedBox(height: 18),

                      /// STRENGTH
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

                      const SizedBox(height: 18),

                      /// DOSE
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

                      const SizedBox(height: 18),

                      /// FREQUENCY
                      const Text(
                        "Frequency",

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
                            value: frequency,

                            isExpanded: true,

                            items:
                                [
                                      "Once Daily",
                                      "Twice Daily",
                                      "Three Times Daily",
                                      "Four Times Daily",
                                    ]
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

                      const SizedBox(height: 18),

                      /// DURATION
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
                      const SizedBox(height: 18),

                      /// NOTES
                      _buildTextField(
                        controller: notesController,

                        label: "Notes",

                        hint: "Additional notes",

                        icon: Icons.notes_outlined,

                        maxLines: 3,
                      ),

                      const SizedBox(height: 35),

                      /// BUTTONS
                      Row(
                        children: [
                          /// CANCEL
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

                                side: BorderSide(color: Colors.grey.shade300),
                              ),

                              child: const Text("Cancel"),
                            ),
                          ),

                          const SizedBox(width: 14),

                          /// SAVE
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.trim().isEmpty) {
                                  setState(() {
                                    medicationNameError =
                                        "Medication name is required";
                                  });
                                  return;
                                }

                                final prescription = Prescription(
                                  prescriptionId: "",

                                  medicationName: nameController.text,

                                  strength: strength,

                                  dose: dose,

                                  notes: notesController.text,

                                  frequency: frequency,

                                  duration:
                                      durationOption == "other"
                                          ? int.tryParse(
                                                durationController.text,
                                              ) ??
                                              3
                                          : int.parse(durationOption),

                                  addedBy: "",

                                  addedByName: "",

                                  issueDate: DateTime.now(),
                                );

                                if (userId != null) {
                                  await prescriptionViewModel
                                      .storeUserPrescription(
                                        userId,
                                        prescription,
                                      );
                                } else {
                                  await prescriptionViewModel.storePrescription(
                                    prescription,
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                elevation: 0,

                                backgroundColor: const Color(0xFF4FC3CF),

                                minimumSize: const Size(0, 56),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              child: const Text(
                                "Save",

                                style: TextStyle(
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

  static void showEditPrescription(
    BuildContext context,
    Prescription prescription, {
    String? userId,
  }) {
    final nameController = TextEditingController(
      text: prescription.medicationName,
    );

    final notesController = TextEditingController(text: prescription.notes);
    String? medicationNameError;

    String frequency = prescription.frequency;
    String strength = prescription.strength;
    String dose = prescription.dose;
    String durationOption =
        [
              "1",
              "3",
              "5",
              "7",
              "14",
              "30",
            ].contains(prescription.duration.toString())
            ? prescription.duration.toString()
            : "other";

    final durationController = TextEditingController(
      text: prescription.duration.toString(),
    );

    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,

              child: Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(28),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Edit Prescription",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildTextField(
                        controller: nameController,

                        label: "Medicine Name",

                        hint: "Enter medicine name",

                        icon: Icons.local_pharmacy_outlined,
                        errorText: medicationNameError,
                      ),

                      const SizedBox(height: 18),

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

                      const SizedBox(height: 18),

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

                      const SizedBox(height: 18),

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
                                [
                                      "Once Daily",
                                      "Twice Daily",
                                      "Three Times Daily",
                                      "Four Times Daily",
                                    ]
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

                      const SizedBox(height: 18),

                      /// DURATION
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

                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: notesController,

                        label: "Notes",

                        hint: "Additional notes",

                        icon: Icons.notes_outlined,

                        maxLines: 3,
                      ),

                      const SizedBox(height: 35),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              child: const Text("Cancel"),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.trim().isEmpty) {
                                  setState(() {
                                    medicationNameError =
                                        "Medication name is required";
                                  });
                                  return;
                                }
                                final updated = prescription.copyWith(
                                  medicationName: nameController.text,

                                  strength: strength,

                                  dose: dose,

                                  notes: notesController.text,

                                  frequency: frequency,

                                  duration:
                                      durationOption == "other"
                                          ? int.tryParse(
                                                durationController.text,
                                              ) ??
                                              prescription.duration
                                          : int.parse(durationOption),
                                );

                                if (userId != null) {
                                  await prescriptionViewModel
                                      .updateUserPrescription(userId, updated);
                                } else {
                                  await prescriptionViewModel
                                      .updatePrescription(updated);
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                elevation: 0,

                                backgroundColor: const Color(0xFF4FC3CF),

                                minimumSize: const Size(0, 56),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              child: const Text(
                                "Update",

                                style: TextStyle(color: Colors.white),
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
    String? errorText,
    int maxLines = 1,
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
          maxLines: maxLines,

          decoration: InputDecoration(
            errorText: errorText,
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

  static Future<bool> showDeleteConfirmation(
    BuildContext context,
    String medicationName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  const Text("Delete Prescription"),
                ],
              ),
              content: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                  children: [
                    const TextSpan(
                      text:
                          "Are you sure you want to delete the prescription for ",
                    ),
                    TextSpan(
                      text: medicationName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: "?\n\nThis action cannot be undone."),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
