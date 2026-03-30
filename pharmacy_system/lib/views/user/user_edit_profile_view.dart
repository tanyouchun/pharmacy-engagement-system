import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_profile_viewmodel.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

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
                controller: userProfileViewModel.nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: userProfileViewModel.ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: userProfileViewModel.genderController,
                decoration: const InputDecoration(labelText: "Gender"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: userProfileViewModel.weightController,
                decoration: const InputDecoration(labelText: "Weight"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: userProfileViewModel.heightController,
                decoration: const InputDecoration(labelText: "Height"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: userProfileViewModel.allergiesController,
                decoration: const InputDecoration(labelText: "Allergies"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: userProfileViewModel.medicalConditionsController,
                decoration: const InputDecoration(labelText: "Medical Conditions"),
              ),

              const SizedBox(height: 25),

              userProfileViewModel.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () async {
                      bool success = await userProfileViewModel.updateProfile();

                      if (success) {
                        Navigator.pop(context); // back to profile
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              userProfileViewModel.errorMessage ?? "Error",
                            ),
                          ),
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
  final parentContext = context;
  final userProfileViewModel = Provider.of<UserProfileViewModel>(
    context,
    listen: false,
  );

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

              bool success = await userProfileViewModel.deleteProfile();

              if (success) {
                Navigator.pop(parentContext); // exit edit page
              } else {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      userProfileViewModel.errorMessage ?? "Delete failed",
                    ),
                  ),
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
