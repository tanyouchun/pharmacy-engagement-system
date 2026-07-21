import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/pharmacist_profile_viewmodel.dart';

/// PharmacistEditProfileView allows pharmacists to update their existing
/// professional profile information.
///
/// Features:
/// - Update pharmacist details.
/// - Save modified information into Firebase through ViewModel.
/// - Delete pharmacist profile with confirmation dialog.
class PharmacistEditProfileView extends StatelessWidget {
  const PharmacistEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(
      context,
    );

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
                "Update Pharmacist Profile",

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                "Keep your professional information updated.",

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
                    /// AVATAR
                    Container(
                      height: 90,
                      width: 90,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [Colors.teal.shade300, Colors.teal.shade700],
                        ),
                      ),

                      child: const Icon(
                        Icons.local_pharmacy,

                        color: Colors.white,
                        size: 46,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// NAME
                    _buildTextField(
                      controller: pharmacistProfileViewModel.nameController,

                      label: "Full Name",

                      hint: "Enter your full name",

                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    /// LICENSE NUMBER
                    _buildTextField(
                      controller: pharmacistProfileViewModel.licenseController,

                      label: "License Number",

                      hint: "Enter license number",

                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 18),

                    /// PHARMACY NAME
                    _buildTextField(
                      controller:
                          pharmacistProfileViewModel.pharmacyNameController,

                      label: "Pharmacy Name",

                      hint: "Enter pharmacy name",

                      icon: Icons.local_hospital_outlined,
                    ),

                    const SizedBox(height: 18),

                    /// EXPERIENCE
                    _buildTextField(
                      controller:
                          pharmacistProfileViewModel.experienceController,

                      label: "Experience (Years)",

                      hint: "e.g. 5 years",

                      icon: Icons.work_outline_rounded,
                    ),

                    const SizedBox(height: 35),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child:
                          pharmacistProfileViewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  bool success =
                                      await pharmacistProfileViewModel
                                          .updateProfile();

                                  if (success) {
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,

                                        content: Text(
                                          pharmacistProfileViewModel
                                                  .errorMessage ??
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

  /// Creates reusable input field component.
  ///
  /// Used for:
  /// - Name
  /// - License number
  /// - Pharmacy name
  /// - Experience
  static Widget _buildTextField({
    required TextEditingController controller,

    required String label,
    required String hint,
    required IconData icon,

    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        /// LABEL
        Text(
          label,

          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),

        const SizedBox(height: 10),

        /// INPUT
        TextField(
          controller: controller,
          keyboardType: keyboardType,

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

/// Displays confirmation dialog before deleting pharmacist profile.
///
/// Prevents accidental deletion by requiring user confirmation.
void _showDeleteDialog(BuildContext context) {
  final parentContext = context;

  final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(
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

              bool success = await pharmacistProfileViewModel.deleteProfile();

              if (success) {
                Navigator.of(parentContext).pushNamedAndRemoveUntil(
                  '/pharmacistProfile',
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,

                    content: Text(
                      pharmacistProfileViewModel.errorMessage ??
                          "Delete failed",
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
