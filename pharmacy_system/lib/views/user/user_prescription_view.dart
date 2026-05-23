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
}
