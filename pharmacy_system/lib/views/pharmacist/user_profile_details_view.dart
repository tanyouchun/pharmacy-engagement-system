import 'package:flutter/material.dart';
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
    final vm = Provider.of<UserProfileViewModel>(context, listen: false);
    await vm.loadUserProfile(widget.userId);
    await vm.loadUserPrescriptions(widget.userId);

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
    final vm = Provider.of<UserProfileViewModel>(context);

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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                final vm = Provider.of<UserProfileViewModel>(
                  context,
                  listen: false,
                );

                ReportHelper.showReportDialog(
                  context: context,
                  reportedUserId: widget.userId,
                  reportedName: vm.name,
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
              vm.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(Icons.cake, "Age", vm.age),
                  _buildStat(Icons.height, "Height", "${vm.height} cm"),
                  _buildStat(Icons.monitor_weight, "Weight", "${vm.weight} kg"),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                  vm.prescriptions.isEmpty
                      ? const Center(
                        child: Text(
                          "No prescriptions found.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: vm.prescriptions.length,
                        itemBuilder: (context, index) {
                          final p = vm.prescriptions[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.medication, size: 40),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  if (!isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditPrescriptionDialog(
                                          p.id,
                                          p.name,
                                        );
                                      },
                                    ),

                                  if (!isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        vm.deletePrescription(
                                          widget.userId,
                                          p.id,
                                        );
                                      },
                                    ),
                                ],
                              ),
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
              : FloatingActionButton(
                onPressed: () {
                  _showAddPrescriptionDialog();
                },
                child: const Icon(Icons.add),
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
                final vm = Provider.of<UserProfileViewModel>(
                  context,
                  listen: false,
                );

                await vm.addPrescription(widget.userId, controller.text, "");

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showEditPrescriptionDialog(String id, String oldName) {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Prescription"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final vm = Provider.of<UserProfileViewModel>(
                  context,
                  listen: false,
                );

                await vm.updatePrescription(
                  widget.userId,
                  id,
                  controller.text,
                  "",
                );

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
