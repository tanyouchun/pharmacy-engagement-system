import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacist_profile_viewmodel.dart';
import 'pharmacist_edit_profile_view.dart';

class PharmacistProfileDisplayView extends StatelessWidget {
  const PharmacistProfileDisplayView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PharmacistProfileViewModel>();

    if (vm.hasProfile && vm.name.isEmpty && !vm.isLoading) {
      // lazy load details the first time we show the screen
      Future.microtask(
        () => context.read<PharmacistProfileViewModel>().loadProfile(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child:
            vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue[100],
                        child: const Icon(Icons.local_pharmacy, size: 50),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        vm.name.isEmpty ? 'Pharmacist' : vm.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _tile('License', vm.license),
                      _tile('Pharmacy', vm.pharmacyName),
                      _tile(
                        'Experience',
                        vm.experience == 0 ? '' : '${vm.experience} yrs',
                      ),
                    ],
                  ),
                ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChangeNotifierProvider.value(
                    value: vm,
                    child: const PharmacistEditProfileView(),
                  ),
            ),
          );
          vm.loadProfile();
        },
        icon: const Icon(Icons.add),
        label: const Text("Edit Profile"),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Card(
      elevation: 0,
      child: ListTile(
        title: Text(label),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }
}
