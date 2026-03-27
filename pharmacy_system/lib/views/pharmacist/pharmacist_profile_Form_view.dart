import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacist_profile_viewmodel.dart';
import '../home_page.dart';
// import '../auth_wrapper.dart';
// import '../../services/auth_service.dart';

class PharmacistProfileFormView extends StatefulWidget {
  const PharmacistProfileFormView({super.key});

  @override
  State<PharmacistProfileFormView> createState() => _PharmacistProfileFormViewState();
}

class _PharmacistProfileFormViewState extends State<PharmacistProfileFormView> {
  final _formKey = GlobalKey<FormState>();

  // Future<void> _logout() async {
  //   try {
  //     await AuthService().signOut();
  //     if (!mounted) return;
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (_) => const AuthWrapper()),
  //       (route) => false,
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Logout failed: $e')),
  //     );
  //   }
  // }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final pharmacistProfileViewModel = context.read<PharmacistProfileViewModel>();

    final ok = await pharmacistProfileViewModel.saveProfile();
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pharmacistProfileViewModel.errorMessage ?? 'Failed to save profile')),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacistProfileViewModel = context.watch<PharmacistProfileViewModel>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: pharmacistProfileViewModel.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pharmacistProfileViewModel.licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pharmacistProfileViewModel.pharmacyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Pharmacy Name',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pharmacistProfileViewModel.experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Years of Experience',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: pharmacistProfileViewModel.isLoading ? null : _saveProfile,
                    child: pharmacistProfileViewModel.isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Save & Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

