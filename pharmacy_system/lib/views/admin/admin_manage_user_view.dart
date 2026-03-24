import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    Future.microtask(() {
      final vm = Provider.of<AdminManageUserViewModel>(context, listen: false);

      vm.listenToUsers();
      vm.listenToReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminManageUserViewModel>(context);

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.userError != null) {
      return Scaffold(body: Center(child: Text("Error: ${vm.userError}")));
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: vm.reports.length,
        itemBuilder: (context, index) {
          final report = vm.reports[index];
          final data = report.data() as Map<String, dynamic>;

          final name = data['reportedName'] ?? "";
          final role = data['reportedRole'] ?? "";
          final reason = data['reason'] ?? "";
          final userId = data['reportedUserId'];

          final userData = vm.getUserData(userId);

          final isBlocked = userData?['isBlocked'] ?? false;
          final suspendUntil = userData?['suspendUntil'];
          final untilDate = (suspendUntil as Timestamp?)?.toDate();

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text("$name ($role)"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Reason: $reason"),

                  if (isBlocked)
                    Text(
                      untilDate != null
                          ? "⏳ Suspended until $untilDate"
                          : "Blocked",
                    )
                  else
                    const Text(
                      "✅ Active",
                      style: TextStyle(color: Colors.green),
                    ),
                ],
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 👁 View
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      _viewProfile(userId, role);
                    },
                  ),

                  /// 🔄 If blocked → show UNSUSPEND
                  if (isBlocked)
                    IconButton(
                      icon: const Icon(Icons.lock_open, color: Colors.green),
                      tooltip: "Unsuspend User",
                      onPressed: () async {
                        final confirm = await _confirmSuspend(
                          "Unsuspend User",
                          "Are you sure you want to unblock this user?",
                        );

                        if (!confirm) return;

                        await vm.unsuspendUser(userId);
                      },
                    )
                  else
                    /// ⛔ If active → show SUSPEND
                    IconButton(
                      icon: const Icon(Icons.block, color: Colors.red),
                      tooltip: "Suspend User",
                      onPressed: () {
                        _showSuspendDialog(vm, userId, report.id);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _viewProfile(String userId, String role) {
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
    AdminManageUserViewModel vm,
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

                    await vm.suspendUser(
                      userId,
                      duration: const Duration(days: 1),
                    );
                    await vm.resolveReport(reportId);
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

                    await vm.suspendUser(
                      userId,
                      duration: const Duration(days: 7),
                    );
                    await vm.resolveReport(reportId);
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

                    await vm.suspendUser(userId, permanent: true);
                    await vm.resolveReport(reportId);
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
}
