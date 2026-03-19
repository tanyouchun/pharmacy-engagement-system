import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/profile_viewmodel.dart';
import 'profile_wrapper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProfileViewModel>(context);

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
                  controller: vm.nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: vm.ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: vm.genderController,
                  decoration: const InputDecoration(labelText: "Gender"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: vm.weightController,
                  decoration: const InputDecoration(labelText: "Weight"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: vm.heightController,
                  decoration: const InputDecoration(labelText: "Height"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: vm.allergiesController,
                  decoration: const InputDecoration(labelText: "Allergies"),
                ),

                const SizedBox(height: 25),

                vm.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        bool success = await vm.saveProfile();

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                vm.errorMessage ?? "Error occurred",
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
