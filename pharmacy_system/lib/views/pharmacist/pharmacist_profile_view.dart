import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacist_profile_viewmodel.dart';
import '../home_page.dart';
import '../auth_wrapper.dart';
import '../../services/auth_service.dart';

class PharmacistProfileView extends StatefulWidget {
  const PharmacistProfileView({super.key});

  @override
  State<PharmacistProfileView> createState() => _PharmacistProfileViewState();
}

class _PharmacistProfileViewState extends State<PharmacistProfileView> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<PharmacistProfileViewModel>();

    final ok = await vm.saveProfile();
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Failed to save profile')),
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
    final vm = context.watch<PharmacistProfileViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacist Profile'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: vm.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: vm.licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: vm.pharmacyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Pharmacy Name',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: vm.experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Years of Experience',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _saveProfile,
                    child: vm.isLoading
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

