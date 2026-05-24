import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../viewmodels/admin_viewmodel.dart';
import '../user/pharmacist_profile_details_view.dart';
import '../pharmacist/user_profile_details_view.dart';

class AdminManageUserView extends StatefulWidget {
  const AdminManageUserView({super.key});

  @override
  State<AdminManageUserView> createState() => _AdminManageUserViewState();
}

class _AdminManageUserViewState extends State<AdminManageUserView> {
  @override
  void initState() {
    super.initState();

    context.read<AdminManageUserViewModel>().initAuthListener();
  }

  @override
  Widget build(BuildContext context) {
    final adminManageUserViewModel = Provider.of<AdminManageUserViewModel>(
      context,
    );

    if (adminManageUserViewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (adminManageUserViewModel.userError != null) {
      return Scaffold(
        body: Center(
          child: Text("Error: ${adminManageUserViewModel.userError}"),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: adminManageUserViewModel.reports.length,
        itemBuilder: (context, index) {
          final report = adminManageUserViewModel.reports[index];

          final name = report.reportedName;
          final role = report.reportedRole;
          final reason = report.reason;
          final userId = report.reportedUserId;

          final userData = adminManageUserViewModel.getUserData(userId);

          final isBlocked = userData?['isBlocked'] ?? false;
          final suspendUntil = userData?['suspendUntil'];
          final untilDate = (suspendUntil as Timestamp?)?.toDate();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// =========================
                  /// TOP USER INFO
                  /// =========================
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            role == 'pharmacist'
                                ? const Color(0xFF4FC3CF)
                                : Colors.deepPurple,

                        child: Icon(
                          role == 'pharmacist'
                              ? Icons.local_pharmacy
                              : Icons.person,

                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildStatusChip(
                        isBlocked: isBlocked,
                        untilDate: untilDate,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// =========================
                  /// REPORT REASON
                  /// =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.report_problem_outlined,
                              color: Colors.orange,
                              size: 18,
                            ),

                            SizedBox(width: 6),

                            Text(
                              "Report Reason",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(reason, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// =========================
                  /// ACTIONS
                  /// =========================
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _checkAccount(userId, role);
                          },

                          icon: const Icon(Icons.visibility_outlined),

                          label: const Text("View Profile"),

                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4FC3CF),
                            side: const BorderSide(color: Color(0xFF4FC3CF)),

                            padding: const EdgeInsets.symmetric(vertical: 14),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child:
                            isBlocked
                                ? ElevatedButton.icon(
                                  icon: const Icon(Icons.lock_open),

                                  label: const Text("Unsuspend"),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),

                                  onPressed: () async {
                                    final confirm = await _confirmSuspend(
                                      "Unsuspend User",
                                      "Are you sure you want to unblock this user?",
                                    );

                                    if (!confirm) return;

                                    await adminManageUserViewModel
                                        .unBlockAccount(userId);
                                  },
                                )
                                : ElevatedButton.icon(
                                  icon: const Icon(Icons.block),

                                  label: const Text("Suspend"),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),

                                  onPressed: () {
                                    _showSuspendDialog(
                                      adminManageUserViewModel,
                                      userId,
                                      report.issueId!,
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _checkAccount(String userId, String role) {
    if (role == 'pharmacist') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PharmacistProfileDetailsView(pharmacistId: userId),
        ),
      );
    } else if (role == 'user') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileDetailsView(userId: userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unknown role, cannot view profile")),
      );
    }
  }

  void _showSuspendDialog(
    AdminManageUserViewModel adminManageUserViewModel,
    String userId,
    String reportId,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Suspend User"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("1 Day"),
                  onTap: () async {
                    Navigator.pop(context);

                    final confirm = await _confirmSuspend(
                      "Confirm Suspension",
                      "Suspend this user for 1 day?",
                    );

                    if (!confirm) return;

                    await adminManageUserViewModel.blockAccount(
                      userId,
                      duration: const Duration(days: 1),
                    );
                    await adminManageUserViewModel.setStatus(reportId);
                  },
                ),

                ListTile(
                  title: const Text("7 Days"),
                  onTap: () async {
                    Navigator.pop(context);

                    final confirm = await _confirmSuspend(
                      "Confirm Suspension",
                      "Suspend this user for 7 days?",
                    );

                    if (!confirm) return;

                    await adminManageUserViewModel.blockAccount(
                      userId,
                      duration: const Duration(days: 7),
                    );
                    await adminManageUserViewModel.setStatus(reportId);
                  },
                ),

                ListTile(
                  title: const Text("Permanent"),
                  onTap: () async {
                    Navigator.pop(context);

                    final confirm = await _confirmSuspend(
                      "Permanent Ban",
                      "Are you sure? This will permanently ban the user.",
                    );

                    if (!confirm) return;

                    await adminManageUserViewModel.blockAccount(
                      userId,
                      permanent: true,
                    );
                    await adminManageUserViewModel.setStatus(reportId);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<bool> _confirmSuspend(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Confirm"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _buildStatusChip({
    required bool isBlocked,
    required DateTime? untilDate,
  }) {
    final isSuspended = isBlocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(
        color:
            isSuspended
                ? Colors.red.withOpacity(0.12)
                : Colors.green.withOpacity(0.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuspended ? Icons.block : Icons.check_circle,
            size: 15,
            color: isSuspended ? Colors.red : Colors.green,
          ),

          const SizedBox(width: 5),

          Text(
            isSuspended
                ? (untilDate != null ? "Suspended" : "Banned")
                : "Active",

            style: TextStyle(
              color: isSuspended ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
