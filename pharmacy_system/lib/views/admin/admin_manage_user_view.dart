import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';

class AdminManageUserView extends StatefulWidget {
  const AdminManageUserView({super.key});

  @override
  State<AdminManageUserView> createState() =>
      _AdminManageUserViewState();
}

class _AdminManageUserViewState
    extends State<AdminManageUserView> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<AdminManageUserViewModel>(
        context,
        listen: false,
      ).listenToUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminManageUserViewModel>(context);

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.error != null) {
      return Scaffold(
        body: Center(child: Text("Error: ${vm.error}")),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: vm.users.length,
        itemBuilder: (context, index) {
          final user = vm.users[index];
          final data = user.data() as Map<String, dynamic>;

          final name = data['name'] ?? "No Name";
          final email = data['email'] ?? "";
          final role = data['role'] ?? "";
          final isBlocked = data['isBlocked'] ?? false;

          if (role == 'admin') return const SizedBox();

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: ListTile(
              title: Text(name),
              subtitle: Text("$email • $role"),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBlocked
                        ? Icons.block
                        : Icons.check_circle,
                    color:
                        isBlocked ? Colors.red : Colors.green,
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isBlocked ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      _confirmAction(vm, user.id, isBlocked);
                    },
                    child: Text(
                      isBlocked ? "Unblock" : "Block",
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmAction(
      AdminManageUserViewModel vm,
      String uid,
      bool isBlocked,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            isBlocked ? "Unblock User" : "Block User"),
        content: Text(
            isBlocked
                ? "Allow this user again?"
                : "Block this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.toggleBlock(uid, isBlocked);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}