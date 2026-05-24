import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/user_profile_viewmodel.dart';
import '../auth_wrapper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text(
                "Personal Information",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                "Complete your healthcare profile information.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 30),

              /// PROFILE CARD
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
                    /// PROFILE AVATAR
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
                                      await userProfileViewModel.saveProfile();

                                  if (success) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const AuthWrapper(),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                          userProfileViewModel.errorMessage ??
                                              "Error occurred",
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
                                  "Save Profile",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
