import 'package:flutter/material.dart';
import 'package:pharmacy_system/utils/prescription_client.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/prescription_viewmodel.dart';

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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// FREQUENCY
                            Container(
                              margin: const EdgeInsets.only(top: 4, bottom: 6),

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

                            /// DATE
                            Text(
                              "Added: ${prescription.issueDate != null ? "${prescription.issueDate!.year}-${prescription.issueDate!.month}-${prescription.issueDate!.day}" : ""}",
                            ),

                            const SizedBox(height: 2),

                            /// PHARMACIST
                            Text("Added By: ${prescription.addedByName}"),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                PrescriptionClient.showEditPrescription(
                                  context,
                                  prescription,
                                );
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
