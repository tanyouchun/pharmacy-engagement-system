import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/prescription_viewmodel.dart';
import '../../models/prescription.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PrescriptionViewModel>().loadPrescriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(context);

    return Scaffold(
      body:
          prescriptionViewModel.isLoadingPrescription
              ? const Center(child: CircularProgressIndicator())
              : prescriptionViewModel.prescriptions.isEmpty
              ? const Center(
                child: Text(
                  "No prescriptions added",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: prescriptionViewModel.prescriptions.length,
                itemBuilder: (context, index) {
                  final prescription =
                      prescriptionViewModel.prescriptions[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.medication),
                        title: Text(prescription.medicineName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Added: ${prescription.issueDate != null ? "${prescription.issueDate!.year}-${prescription.issueDate!.month}-${prescription.issueDate!.day}" : ""}",
                            ),
                            Text("Added By: ${prescription.addedByName}"),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(context, prescription);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                prescriptionViewModel.deletePrescription(
                                  prescription.prescriptionId,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddDialog(context);
        },
        backgroundColor: const Color(0xFF4FC3CF),
        foregroundColor: Colors.black,
        label: const Text("Add new prescription"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

void _showAddDialog(BuildContext context) {
  final nameController = TextEditingController();
  final notesController = TextEditingController();

  final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
    context,
    listen: false,
  );

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Add Prescription"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
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
                await prescriptionViewModel.addPrescription(
                  Prescription(
                    prescriptionId: "",
                    medicineName: nameController.text,
                    notes: notesController.text,
                    addedBy: "",
                    addedByName: "",
                    issueDate: DateTime.now(),
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
  );
}

void _showEditDialog(BuildContext context, Prescription prescription) {
  final nameController = TextEditingController(text: prescription.medicineName);
  final notesController = TextEditingController(text: prescription.notes);

  showDialog(
    context: context,
    builder: (dialogContext) {
      final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
        dialogContext,
        listen: false,
      );
      return AlertDialog(
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
              try {
                await prescriptionViewModel.updatePrescription(
                  prescription.copyWith(
                    medicineName: nameController.text,
                    notes: notesController.text,
                  ),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                log("Update error: $e");
              }
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}
