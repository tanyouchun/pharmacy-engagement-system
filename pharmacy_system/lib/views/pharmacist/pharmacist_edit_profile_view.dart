import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacist_profile_viewmodel.dart';

class PharmacistEditProfileView extends StatelessWidget {
  const PharmacistEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(context);

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
                controller: pharmacistProfileViewModel.nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: pharmacistProfileViewModel.licenseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "License Number"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: pharmacistProfileViewModel.pharmacyNameController,
                decoration: const InputDecoration(labelText: "Pharmacy Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: pharmacistProfileViewModel.experienceController,
                decoration: const InputDecoration(
                  labelText: "Experience (years)",
                ),
              ),

              const SizedBox(height: 25),

              pharmacistProfileViewModel.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () async {
                      bool success = await pharmacistProfileViewModel.updateProfile();

                      if (success) {
                        Navigator.pop(context); // back to profile
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(pharmacistProfileViewModel.errorMessage ?? "Error")),
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

//TODO: force pharmacist to create new profile if they want to use the app again after deletion.
void _showDeleteDialog(BuildContext context) {
  final parentContext = context;
  final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(context, listen: false);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Delete Profile"),
        content: const Text(
          "Are you sure you want to delete your profile? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // AF1: Cancel
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // close dialog

              bool success = await pharmacistProfileViewModel.deleteProfile();

              if (success) {
                Navigator.of(parentContext).pushNamedAndRemoveUntil(
                  '/pharmacistProfile',
                  (route) => false, // remove ALL previous screens
                );
              } else {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(content: Text(pharmacistProfileViewModel.errorMessage ?? "Delete failed")),
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
