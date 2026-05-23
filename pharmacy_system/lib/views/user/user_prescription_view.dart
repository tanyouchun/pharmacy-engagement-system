import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/prescription_viewmodel.dart';
import 'package:pharmacy_system/utils/prescription_client.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmacy_system/utils/reminder_client.dart';

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
                    child: Slidable(
                      key: ValueKey(prescription.prescriptionId),

                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.85,

                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              PrescriptionClient.showEditPrescription(
                                context,
                                prescription,
                              );
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                            borderRadius: BorderRadius.circular(16),
                          ),

                          SlidableAction(
                            onPressed: (_) {
                              prescriptionViewModel.deletePrescription(
                                prescription.prescriptionId,
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(16),
                          ),

                          SlidableAction(
                            onPressed: (_) {
                              ReminderClient.showReminderFormFromPrescription(
                                context,
                                medicineName: prescription.medicineName,
                                frequency: prescription.frequency,
                              );
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.alarm_add,
                            label: 'Reminder',
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ],
                      ),

                      child: Card(
                        elevation: 2,
                        color: const Color(0xFFEAF4FF),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        shadowColor: Colors.black.withOpacity(0.15),
                        child: ListTile(
                          onTap:
                              () => _showPrescriptionDetails(
                                context,
                                prescription,
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
                          title: Text(prescription.medicineName),
                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 4,
                                        bottom: 6,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        prescription.frequency,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 2),

                                  Text(
                                    prescription.issueDate != null
                                        ? "AddedTime: ${prescription.issueDate!.year}-${prescription.issueDate!.month}-${prescription.issueDate!.day}"
                                        : "",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    "AddedBy: ${prescription.addedByName}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          PrescriptionClient.showAddPrescription(context: context);
        },
        backgroundColor: const Color(0xFF4FC3CF),
        foregroundColor: Colors.black,
        label: const Text("Add new prescription"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showPrescriptionDetails(BuildContext context, prescription) {
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
                    // Handle bar
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

                    // Title Section
                    Row(
                      children: [
                        const Icon(
                          Icons.medication,
                          color: Colors.blue,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            prescription.medicineName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Frequency Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Frequency: ${prescription.frequency}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Notes
                          if (prescription.notes != null &&
                              prescription.notes.toString().trim().isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Notes",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  prescription.notes,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 12),
                              ],
                            ),

                          // Date
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                prescription.issueDate != null
                                    ? "Date: ${prescription.issueDate!.year}-${prescription.issueDate!.month}-${prescription.issueDate!.day}"
                                    : "Date: -",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Added by
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Added by: ${prescription.addedByName}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
