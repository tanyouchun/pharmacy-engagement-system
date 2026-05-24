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
      backgroundColor: const Color(0xFFF4F7FB),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 32, bottom: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FC3CF), Color(0xFF6FE7F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),

              child: Column(
                children: [
                  /// AVATAR
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.local_pharmacy,
                        size: 42,
                        color: const Color(0xFF4FC3CF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// NAME
                  Text(
                    vm.name.isEmpty ? "Pharmacist" : vm.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    vm.pharmacyName.isEmpty ? "Pharmacy" : vm.pharmacyName,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.badge,
                      title: "License",
                      value: vm.license.isEmpty ? "-" : vm.license,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.work,
                      title: "Experience",
                      value: vm.experience == 0 ? "-" : "${vm.experience} yrs",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_pharmacy,
                      title: "Status",
                      value: "Active",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// INFO CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF4FC3CF)),
                        SizedBox(width: 8),
                        Text(
                          "Pharmacist Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Manage your pharmacy credentials and professional information here.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      /// EDIT BUTTON
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
        backgroundColor: const Color(0xFF4FC3CF),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profile"),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4FC3CF)),

          const SizedBox(height: 6),

          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
