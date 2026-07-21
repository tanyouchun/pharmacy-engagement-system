import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/user_profile_viewmodel.dart';

/// EditProfileView allows users to update their existing healthcare profile.
///
/// Users can modify:
/// - Personal information
/// - Physical information
/// - Allergy information
/// - Medical conditions
class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// HEADER
              const Text(
                "Update Your Profile",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                "Keep your health information updated.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 30),

              /// CARD
              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: 90,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [Colors.blue.shade300, Colors.blue.shade700],
                        ),
                      ),

                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// NAME
                    _buildTextField(
                      controller: userProfileViewModel.nameController,
                      label: "Full Name",
                      hint: "Enter your name",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    /// AGE
                    _buildTextField(
                      controller: userProfileViewModel.ageController,
                      label: "Age",
                      hint: "Enter your age",
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 18),

                    /// GENDER
                    _buildTextField(
                      controller: userProfileViewModel.genderController,
                      label: "Gender",
                      hint: "Male / Female",
                      icon: Icons.wc_outlined,
                    ),

                    const SizedBox(height: 18),

                    /// WEIGHT
                    _buildTextField(
                      controller: userProfileViewModel.weightController,
                      label: "Weight",
                      hint: "e.g. 70 kg",
                      icon: Icons.monitor_weight_outlined,
                    ),

                    const SizedBox(height: 18),

                    /// HEIGHT
                    _buildTextField(
                      controller: userProfileViewModel.heightController,
                      label: "Height",
                      hint: "e.g. 170 cm",
                      icon: Icons.height_outlined,
                    ),

                    const SizedBox(height: 18),

                    /// ALLERGIES
                    _buildTextField(
                      controller: userProfileViewModel.allergiesController,
                      label: "Allergies",
                      hint: "Enter allergies",
                      icon: Icons.warning_amber_rounded,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 18),

                    /// MEDICAL CONDITIONS
                    _buildTextField(
                      controller:
                          userProfileViewModel.medicalConditionsController,
                      label: "Medical Conditions",
                      hint: "Enter medical conditions",
                      icon: Icons.local_hospital_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 35),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child:
                          userProfileViewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  bool success =
                                      await userProfileViewModel
                                          .updateProfile();

                                  if (success) {
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,

                                        content: Text(
                                          userProfileViewModel.errorMessage ??
                                              "Error",
                                        ),
                                      ),
                                    );
                                  }
                                },

                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF4FC3CF),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                child: const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                    ),

                    const SizedBox(height: 18),

                    /// DELETE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,

                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showDeleteDialog(context);
                        },

                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),

                        label: const Text(
                          "Delete Profile",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade200),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable text field component for profile information input.
  ///
  /// This method reduces duplicate UI code by generating
  /// consistent text fields for different profile attributes.
  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,

          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(icon),

            filled: true,
            fillColor: Colors.grey.shade100,

            contentPadding: const EdgeInsets.symmetric(vertical: 18),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF4FC3CF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays confirmation dialog before deleting user profile.
///
/// The dialog prevents accidental deletion by requiring
/// user confirmation before executing deleteProfile().
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),

            SizedBox(width: 10),

            Text("Delete Profile"),
          ],
        ),

        content: const Text(
          "Are you sure you want to delete your profile? This action cannot be undone.",
        ),

        actions: [
          /// CANCEL
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },

            child: const Text("Cancel"),
          ),

          /// DELETE
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              bool success = await userProfileViewModel.deleteProfile();

              if (success) {
                Navigator.pop(parentContext);
              } else {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,

                    content: Text(
                      userProfileViewModel.errorMessage ?? "Delete failed",
                    ),
                  ),
                );
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
