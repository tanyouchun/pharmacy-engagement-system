import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_wrapper.dart';

/// Displays a waiting screen for pharmacists whose accounts
/// have not yet been approved or have been rejected by the admin.
class PharmacistPendingApprovalView extends StatelessWidget {
  final String approvalStatus;

  const PharmacistPendingApprovalView({
    super.key,
    required this.approvalStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = approvalStatus == 'rejected';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRejected ? Icons.cancel : Icons.hourglass_top,
                size: 80,
                color: isRejected ? Colors.red : const Color(0xFF4FC3CF),
              ),

              const SizedBox(height: 20),

              Text(
                isRejected ? "Account Rejected" : "Account Pending Approval",

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                isRejected
                    ? "Your pharmacist application was rejected by admin.\nPlease contact support or submit again."
                    : "Your pharmacist account is under review by admin.\nYou will be able to access the system once approved.",

                textAlign: TextAlign.center,

                style: TextStyle(color: isRejected ? Colors.red : Colors.grey),
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                },

                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
