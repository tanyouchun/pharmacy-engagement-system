import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/pharmacist_profile_viewmodel.dart';
import '../home_page.dart';

class PharmacistProfileFormView extends StatefulWidget {
  const PharmacistProfileFormView({super.key});

  @override
  State<PharmacistProfileFormView> createState() =>
      _PharmacistProfileFormViewState();
}

class _PharmacistProfileFormViewState extends State<PharmacistProfileFormView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final pharmacistProfileViewModel =
        context.watch<PharmacistProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          "Pharmacist Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// HEADER
                const Text(
                  "Professional Information",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  "Complete your pharmacist profile details.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),

                const SizedBox(height: 30),

                /// MAIN CARD
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
                            colors: [
                              Colors.teal.shade300,
                              Colors.teal.shade700,
                            ],
                          ),
                        ),

                        child: const Icon(
                          Icons.local_pharmacy,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// FULL NAME
                      _buildTextField(
                        controller: pharmacistProfileViewModel.nameController,

                        label: "Full Name",
                        hint: "Enter your full name",

                        icon: Icons.person_outline,

                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? 'Required'
                                    : null,
                      ),

                      const SizedBox(height: 18),

                      /// LICENSE NUMBER
                      _buildTextField(
                        controller:
                            pharmacistProfileViewModel.licenseController,

                        label: "License Number",
                        hint: "Enter pharmacist license",

                        icon: Icons.badge_outlined,

                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? 'Required'
                                    : null,
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

                        label: "Years of Experience",

                        hint: "Enter years of experience",

                        icon: Icons.work_outline_rounded,

                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 58,

                        child:
                            pharmacistProfileViewModel.isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ElevatedButton(
                                  onPressed: _saveProfile,

                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,

                                    backgroundColor: const Color(0xFF4FC3CF),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),

                                  child: const Text(
                                    'Save & Continue',

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
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pharmacistProfileViewModel =
        context.read<PharmacistProfileViewModel>();

    final ok = await pharmacistProfileViewModel.saveProfile();

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          content: Text(
            pharmacistProfileViewModel.errorMessage ?? 'Failed to save profile',
          ),
        ),
      );

      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,

    String? Function(String?)? validator,

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
        TextFormField(
          controller: controller,
          validator: validator,
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
