import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/user_profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
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
                        FocusScope.of(context).unfocus();

                        bool success = await userProfileViewModel.saveProfile();

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                userProfileViewModel.errorMessage ?? "Error occurred",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Save"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
