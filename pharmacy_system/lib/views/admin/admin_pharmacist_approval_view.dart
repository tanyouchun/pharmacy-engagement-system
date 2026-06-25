import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPharmacistApprovalView extends StatelessWidget {
  const AdminPharmacistApprovalView({super.key});

  Future<void> _updateStatus(String userId, String status) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'approvalStatus': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'pharmacist')
                .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;

          if (allDocs.isEmpty) {
            return const Center(child: Text("No pharmacist accounts found"));
          }

          /// Separate sections
          final pendingDocs =
              allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['approvalStatus'] ?? 'pending') == 'pending';
              }).toList();

          final reviewedDocs =
              allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['approvalStatus'] ?? 'pending') != 'pending';
              }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// =========================
                /// PENDING SECTION
                /// =========================
                const Text(
                  "New Pharmacist Accounts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  "${pendingDocs.length} account(s) waiting for approval",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                if (pendingDocs.isEmpty)
                  _buildEmptySection(
                    icon: Icons.verified_user_outlined,
                    text: "No pending approvals",
                  ),

                ...pendingDocs.map((doc) => _buildPharmacistCard(context, doc)),

                const SizedBox(height: 32),

                /// =========================
                /// REVIEWED SECTION
                /// =========================
                const Text(
                  "Reviewed Accounts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  "${reviewedDocs.length} reviewed account(s)",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                if (reviewedDocs.isEmpty)
                  _buildEmptySection(
                    icon: Icons.history,
                    text: "No reviewed accounts yet",
                  ),

                ...reviewedDocs.map(
                  (doc) => _buildPharmacistCard(context, doc),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: const Color(0xFF4FC3CF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, color: const Color(0xFF4FC3CF), size: 20),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'approved':
        bgColor = Colors.green.withOpacity(0.12);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;

      case 'rejected':
        bgColor = Colors.red.withOpacity(0.12);
        textColor = Colors.red;
        icon = Icons.cancel;
        break;

      default:
        bgColor = Colors.orange.withOpacity(0.12);
        textColor = Colors.orange;
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),

          const SizedBox(width: 4),

          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 40),

          const SizedBox(height: 10),

          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacistCard(BuildContext context, QueryDocumentSnapshot doc) {
    final userData = doc.data() as Map<String, dynamic>;
    final userId = doc.id;
    final status = userData['approvalStatus'] ?? 'pending';

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('pharmacist_profiles')
              .doc(userId)
              .get(),

      builder: (context, profileSnapshot) {
        if (!profileSnapshot.hasData) {
          return const SizedBox();
        }

        final profileData =
            profileSnapshot.data!.data() as Map<String, dynamic>?;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),

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

          child: Padding(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP HEADER
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFF4FC3CF),
                      child: Icon(Icons.local_pharmacy, color: Colors.white),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  profileData?['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              _buildStatusBadge(status),
                            ],
                          ),

                          const SizedBox(height: 3),

                          Text(
                            userData['email'] ?? '-',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// DETAILS
                _buildInfoTile(
                  Icons.badge_outlined,
                  "License",
                  profileData?['license'] ?? '-',
                ),

                const SizedBox(height: 12),

                _buildInfoTile(
                  Icons.local_pharmacy_outlined,
                  "Pharmacy",
                  profileData?['pharmacyName'] ?? '-',
                ),

                const SizedBox(height: 12),

                _buildInfoTile(
                  Icons.work_outline,
                  "Experience",
                  "${profileData?['experience'] ?? 0} years",
                ),

                const SizedBox(height: 20),

                /// ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            status == 'pending'
                                ? () => _showConfirmationDialog(
                                  context: context,
                                  userId: userId,
                                  status: "rejected",
                                )
                                : null,

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              status == 'pending'
                                  ? Colors.red
                                  : Colors.grey.shade300,

                          foregroundColor:
                              status == 'pending'
                                  ? Colors.white
                                  : Colors.grey.shade600,

                          elevation: 0,

                          disabledBackgroundColor: Colors.grey.shade300,

                          disabledForegroundColor: Colors.grey.shade600,

                          padding: const EdgeInsets.symmetric(vertical: 14),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: const Text(
                          "Reject",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            status == 'pending'
                                ? () => _showConfirmationDialog(
                                  context: context,
                                  userId: userId,
                                  status: "approved",
                                )
                                : null,

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              status == 'pending'
                                  ? const Color(0xFF4FC3CF)
                                  : Colors.grey.shade300,

                          foregroundColor:
                              status == 'pending'
                                  ? Colors.white
                                  : Colors.grey.shade600,

                          elevation: 0,

                          disabledBackgroundColor: Colors.grey.shade300,

                          disabledForegroundColor: Colors.grey.shade600,

                          padding: const EdgeInsets.symmetric(vertical: 14),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: const Text(
                          "Approve",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String userId,
    required String status,
  }) async {
    final isApprove = status == 'approved';

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: Row(
              children: [
                Icon(
                  isApprove ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isApprove ? Colors.green : Colors.red,
                ),

                const SizedBox(width: 10),

                Text(isApprove ? "Approve Pharmacist" : "Reject Pharmacist"),
              ],
            ),

            content: Text(
              isApprove
                  ? "Are you sure you want to approve this pharmacist account?"
                  : "Are you sure you want to reject this pharmacist account?",
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),

              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isApprove ? const Color(0xFF4FC3CF) : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text(isApprove ? "Approve" : "Reject"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _updateStatus(userId, status);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApprove
                ? "Pharmacist approved successfully"
                : "Pharmacist rejected",
          ),
        ),
      );
    }
  }
}
