import 'package:flutter/material.dart';
import 'package:pharmacy_system/models/prescription.dart';
import 'package:pharmacy_system/viewmodels/prescription_viewmodel.dart';
import 'package:pharmacy_system/widgets/prescription_function.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../viewmodels/user_profile_viewmodel.dart';
import '../../utils/report_helper.dart';

class UserProfileDetailsView extends StatefulWidget {
  final String userId;
  const UserProfileDetailsView({super.key, required this.userId});

  @override
  State<UserProfileDetailsView> createState() => _UserProfileDetailsViewState();
}

class _UserProfileDetailsViewState extends State<UserProfileDetailsView> {
  bool isLoading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(
      context,
      listen: false,
    );
    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );
    await userProfileViewModel.loadUserProfile(widget.userId);
    await prescriptionViewModel.loadUserPrescriptions(widget.userId);

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      final role = doc.data()?['role'];

      isAdmin = role == 'admin';
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);
    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // allow pharmacist to report user to Admin
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                final userProfileViewModel = Provider.of<UserProfileViewModel>(
                  context,
                  listen: false,
                );

                ReportHelper.reportAccount(
                  context: context,
                  reportedUserId: widget.userId,
                  reportedName: userProfileViewModel.name,
                  reportedRole: "user",
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'report', child: Text("Report")),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            //TODO: replace with real profile picture
            CircleAvatar(
              radius: 50,
              // backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
            ),

            const SizedBox(height: 10),

            Text(
              userProfileViewModel.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(Icons.cake, "Age", userProfileViewModel.age),
                  _buildStat(
                    Icons.height,
                    "Height",
                    "${userProfileViewModel.height} cm",
                  ),
                  _buildStat(
                    Icons.monitor_weight,
                    "Weight",
                    "${userProfileViewModel.weight} kg",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Medical Conditions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  userProfileViewModel.medicalConditions.isEmpty
                      ? const Text(
                        "No medical conditions",
                        style: TextStyle(color: Colors.grey),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            userProfileViewModel.medicalConditions
                                .split(',')
                                .map(
                                  (condition) => Chip(
                                    label: Text(condition.trim()),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                )
                                .toList(),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Prescription history:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child:
                  prescriptionViewModel.prescriptions.isEmpty
                      ? const Center(
                        child: Text(
                          "No prescriptions found.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: prescriptionViewModel.prescriptions.length,
                        itemBuilder: (context, index) {
                          final prescription =
                              prescriptionViewModel.prescriptions[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
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
                              trailing:
                                  !isAdmin
                                      ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              PrescriptionFunction.showEdit(
                                                context,
                                                prescription,
                                                userId:
                                                    widget.userId, // important
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              prescriptionViewModel
                                                  .deleteUserPrescription(
                                                    widget.userId,
                                                    prescription.prescriptionId,
                                                  );
                                            },
                                          ),
                                        ],
                                      )
                                      : null,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          isAdmin
              ? null
              : FloatingActionButton.extended(
                onPressed: () {
                  _showAddPrescriptionDialog();
                },
                backgroundColor: const Color(0xFF4FC3CF),
                foregroundColor: Colors.black,
                label: const Text("Add new prescription"),
                icon: const Icon(Icons.add),
              ),
    );
  }

  Widget _buildStat(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  //TODO function can include in one file for user_prescription_view
  void _showAddPrescriptionDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Prescription"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final prescriptionViewModel =
                    Provider.of<PrescriptionViewModel>(context, listen: false);

                await prescriptionViewModel.storeUserPrescription(
                  widget.userId,
                  Prescription(
                    prescriptionId: "",
                    medicineName: controller.text,
                    notes: "",
                    addedBy: "",
                    addedByName: "",
                    issueDate: null,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // void _showEditPrescriptionDialog(
  //   String id,
  //   String oldName,
  //   Prescription prescription,
  // ) {
  //   final controller = TextEditingController(text: oldName);

  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return AlertDialog(
  //         title: const Text("Edit Prescription"),
  //         content: TextField(controller: controller),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               final prescriptionViewModel =
  //                   Provider.of<PrescriptionViewModel>(context, listen: false);

  //               await prescriptionViewModel.updateUserPrescription(
  //                 widget.userId,
  //                 prescription.copyWith(
  //                   medicineName: controller.text,
  //                   notes: "",
  //                 ),
  //               );

  //               Navigator.pop(context);
  //             },
  //             child: const Text("Save"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
