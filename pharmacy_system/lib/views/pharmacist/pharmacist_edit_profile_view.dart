import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacist_profile_viewmodel.dart';

class PharmacistEditProfileView extends StatelessWidget {
  const PharmacistEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PharmacistProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // AF1: Cancel
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: vm.nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: vm.licenseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "License Number"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: vm.pharmacyNameController,
                decoration: const InputDecoration(labelText: "Pharmacy Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: vm.experienceController,
                decoration: const InputDecoration(labelText: "Experience (years)"),
              ),

              const SizedBox(height: 25),

              vm.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () async {
                      bool success = await vm.updateProfile();

                      if (success) {
                        Navigator.pop(context); // back to profile
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vm.errorMessage ?? "Error")),
                        );
                      }
                    },
                    child: const Text("Save Changes"),
                  ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  _showDeleteDialog(context);
                },
                child: const Text(
                  "Delete Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context) {
  final vm = Provider.of<PharmacistProfileViewModel>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete Profile"),
        content: const Text(
          "Are you sure you want to delete your profile? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // AF1: Cancel
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog

              bool success = await vm.deleteProfile();

              if (success) {
                Navigator.pop(context); // exit edit page
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage ?? "Delete failed")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
