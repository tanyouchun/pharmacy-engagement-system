import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prescription.dart';
import '../viewmodels/prescription_viewmodel.dart';

class PrescriptionClient {

  static void showAddPrescription({
    required BuildContext context,
    String? userId, // optional → if provided, use storeUserPrescription
  }) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();

    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Prescription"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Medicine Name"),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final prescription = Prescription(
                  prescriptionId: "",
                  medicineName: nameController.text,
                  notes: notesController.text,
                  addedBy: "",
                  addedByName: "",
                  issueDate: DateTime.now(),
                );

                if (userId != null) {
                  // Call pharmacist function
                  await prescriptionViewModel.storeUserPrescription(
                    userId,
                    prescription,
                  );
                } else {
                  // Call user function
                  await prescriptionViewModel.storePrescription(prescription);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
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

    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Edit Prescription"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController),
                TextField(controller: notesController),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final updated = prescription.copyWith(
                    medicineName: nameController.text,
                    notes: notesController.text,
                  );

                  if (userId != null) {
                    await prescriptionViewModel.updateUserPrescription(
                      userId,
                      updated,
                    );
                  } else {
                    await prescriptionViewModel.updatePrescription(updated);
                  }

                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }
}
