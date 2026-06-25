import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../viewmodels/admin_viewmodel.dart';

class ReportClient {
  static void reportAccount({
    required BuildContext context,
    required String reportedUserId,
    required String reportedName,
    required String reportedRole,
  }) {
    String selectedReason = "Spam / irrelevant content";
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.report, color: Colors.red),
                  const SizedBox(width: 8),
                  Text("Report $reportedRole"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reason",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: selectedReason,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items:
                            const [
                                  "Spam / irrelevant content",
                                  "Fake account / identity",
                                  "Harassment or abuse",
                                  "Incorrect medical info",
                                  "Other",
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      isSubmitting
                          ? null
                          : () async {
                            setState(() => isSubmitting = true);

                            await _submitReport(
                              context: context,
                              reportedUserId: reportedUserId,
                              reportedName: reportedName,
                              reportedRole: reportedRole,
                              reason: selectedReason,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Report submitted successfully",
                                  ),
                                ),
                              );
                            }
                          },
                  child:
                      isSubmitting
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> _submitReport({
    required BuildContext context,
    required String reportedUserId,
    required String reportedName,
    required String reportedRole,
    required String reason,
  }) async {
    final vm = Provider.of<AdminManageUserViewModel>(context, listen: false);

    final currentUser = FirebaseAuth.instance.currentUser;

    try {
      final success = await vm.submitReport(
        reportedUserId: reportedUserId,
        reportedName: reportedName,
        reportedRole: reportedRole,
        reportedBy: currentUser?.uid,
        reason: reason,
      );

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.reportError ?? "Failed to submit report")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
