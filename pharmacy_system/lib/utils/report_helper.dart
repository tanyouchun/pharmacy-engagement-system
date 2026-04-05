import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../viewmodels/admin_viewmodel.dart';

class ReportHelper {
  static void reportAccount({
    required BuildContext context,
    required String reportedUserId,
    required String reportedName,
    required String reportedRole, // "user" or "pharmacist"
  }) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Report ${reportedRole == 'pharmacist' ? 'Pharmacist' : 'User'}"),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter reason (e.g. spam, fake account...)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _submitReport(
                context: context,
                reportedUserId: reportedUserId,
                reportedName: reportedName,
                reportedRole: reportedRole,
                reason: reasonController.text,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report submitted")),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  static Future<void> _submitReport({
    required BuildContext context,
    required String reportedUserId,
    required String reportedName,
    required String reportedRole,
    required String reason,
  }) async {
    final adminManageUserViewModel = Provider.of<AdminManageUserViewModel>(
      context,
      listen: false,
    );

    final currentUser = FirebaseAuth.instance.currentUser;

    final success = await adminManageUserViewModel.submitReport(
      reportedUserId: reportedUserId,
      reportedName: reportedName,
      reportedRole: reportedRole,
      reportedBy: currentUser?.uid,
      reason: reason,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminManageUserViewModel.reportError ?? "Failed")),
      );
    }
  }
}