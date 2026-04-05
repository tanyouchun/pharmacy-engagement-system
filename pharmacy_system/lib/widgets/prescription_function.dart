import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prescription.dart';
import '../viewmodels/prescription_viewmodel.dart';

class PrescriptionFunction {
  static void showEdit(
    BuildContext context,
    Prescription prescription, {
    String? userId,
  }) {
    final nameController =
        TextEditingController(text: prescription.medicineName);
    final notesController =
        TextEditingController(text: prescription.notes);

    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                await prescriptionViewModel.updateUserPrescription(userId, updated);
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