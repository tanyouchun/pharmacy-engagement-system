import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../viewmodels/user_profile_viewmodel.dart';
import '../../utils/report_client.dart';
import 'package:pharmacy_system/viewmodels/prescription_viewmodel.dart';
import 'package:pharmacy_system/utils/prescription_client.dart';

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
    await prescriptionViewModel.loadPrescriptionVisibility(widget.userId);

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

                ReportClient.reportAccount(
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// TOP HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 28, bottom: 16),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4FC3CF), Color(0xFF6FE7F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),

                child: Column(
                  children: [
                    /// PROFILE IMAGE
                    Container(
                      padding: const EdgeInsets.all(3),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),

                      child: const CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,

                        child: Icon(
                          Icons.person,
                          size: 42,
                          color: Color(0xFF4FC3CF),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      userProfileViewModel.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      userProfileViewModel.gender,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// STATS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.cake,
                        title: "Age",
                        value: userProfileViewModel.age,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.height,
                        title: "Height",
                        value: "${userProfileViewModel.height} cm",
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.monitor_weight,
                        title: "Weight",
                        value: "${userProfileViewModel.weight} kg",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ALLERGIES SECTION
              _buildSectionCard(
                title: "Allergies",
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,

                child:
                    userProfileViewModel.allergies.isEmpty
                        ? const Text(
                          "No allergies recorded",
                          style: TextStyle(color: Colors.grey),
                        )
                        : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              userProfileViewModel.allergies
                                  .split(',')
                                  .map(
                                    (allergy) => Chip(
                                      label: Text(allergy.trim()),
                                      backgroundColor: Colors.orange.shade50,
                                    ),
                                  )
                                  .toList(),
                        ),
              ),

              const SizedBox(height: 18),

              /// MEDICAL CONDITIONS
              _buildSectionCard(
                title: "Medical Conditions",
                icon: Icons.favorite,
                iconColor: Colors.redAccent,

                child:
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
              ),

              const SizedBox(height: 30),

              /// PRESCRIPTION TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Prescription History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (!prescriptionViewModel.isPrescriptionVisible)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "This user's prescription history is private.",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child:
                      prescriptionViewModel.prescriptions.isEmpty
                          ? const Center(
                            child: Text(
                              "No prescriptions found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 200),
                            itemCount:
                                prescriptionViewModel.prescriptions.length,
                            itemBuilder: (context, index) {
                              final prescription =
                                  prescriptionViewModel.prescriptions[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: Slidable(
                                  key: ValueKey(prescription.prescriptionId),

                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.5,

                                    children: [
                                      SlidableAction(
                                        onPressed: (_) {
                                          PrescriptionClient.showEditPrescription(
                                            context,
                                            prescription,
                                            userId: widget.userId,
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
                                          prescriptionViewModel
                                              .deleteUserPrescription(
                                                widget.userId,
                                                prescription.prescriptionId,
                                              );
                                        },
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
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

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
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

                                      title: Text(
                                        prescription.medicineName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      subtitle: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 6,
                                                    bottom: 6,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    prescription.frequency,
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                ),
            ],
          ),
        ),
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          isAdmin
              ? null
              : FloatingActionButton.extended(
                onPressed: () {
                  PrescriptionClient.showAddPrescription(
                    context: context,
                    userId: widget.userId,
                  );
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4FC3CF)),

          const SizedBox(height: 8),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),

                const SizedBox(width: 8),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    );
  }
}
