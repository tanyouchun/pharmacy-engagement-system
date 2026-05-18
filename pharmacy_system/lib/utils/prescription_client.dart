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

    String frequency = "Once daily";

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
                                      "Once daily",
                                      "Twice daily",
                                      "Thrice daily",
                                      "Every 6 hours",
                                      "Every 8 hours",
                                      "Every 12 hours",
                                      "Every 24 hours",
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
                                final prescription = Prescription(
                                  prescriptionId: "",

                                  medicineName: nameController.text,

                                  notes: notesController.text,

                                  frequency: frequency,

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
      text: prescription.medicineName,
    );

    final notesController = TextEditingController(text: prescription.notes);

    String frequency = prescription.frequency;

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
                                      "Once daily",
                                      "Twice daily",
                                      "Thrice daily",
                                      "Every 6 hours",
                                      "Every 8 hours",
                                      "Every 12 hours",
                                      "Every 24 hours",
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
                                final updated = prescription.copyWith(
                                  medicineName: nameController.text,

                                  notes: notesController.text,

                                  frequency: frequency,
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
}
