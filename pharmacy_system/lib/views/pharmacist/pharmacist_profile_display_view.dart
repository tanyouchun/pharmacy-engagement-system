import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacist_profile_viewmodel.dart';
import 'pharmacist_edit_profile_view.dart';

class PharmacistProfileDisplayView extends StatefulWidget {
  const PharmacistProfileDisplayView({super.key});

  @override
  State<PharmacistProfileDisplayView> createState() =>
      _PharmacistProfileDisplayViewState();
}

class _PharmacistProfileDisplayViewState
    extends State<PharmacistProfileDisplayView> {
  // bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PharmacistProfileViewModel>().loadProfile();
    });
  }

  // Future<void> _loadData() async {
  //   final vm = context.read<PharmacistProfileViewModel>();

  //   await vm.loadProfile();

  //   if (!mounted) return;
  // }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PharmacistProfileViewModel>(context);

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!vm.hasProfile) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/pharmacistProfile');
      });

      return const SizedBox();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// 👤 Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.local_pharmacy, size: 50),
            ),

            const SizedBox(height: 10),

            /// 👤 Name
            Text(
              vm.name.isEmpty ? 'Pharmacist' : vm.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 📊 Stats (MATCH USER UI)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(Icons.badge, "License", vm.license),
                  _buildStat(Icons.local_pharmacy, "Pharmacy", vm.pharmacyName),
                  _buildStat(
                    Icons.work,
                    "Experience",
                    vm.experience == 0 ? "-" : "${vm.experience} yrs",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChangeNotifierProvider.value(
                    value: vm,
                    child: const PharmacistEditProfileView(),
                  ),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profile"),
      ),
    );
  }

  /// 🔹 SAME STYLE as UserProfile
  Widget _buildStat(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? "-" : value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
