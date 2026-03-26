import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import 'user_edit_profile_view.dart';

class UserProfileDisplayView extends StatefulWidget {
  const UserProfileDisplayView({super.key});

  @override
  State<UserProfileDisplayView> createState() => _UserProfileDisplayViewState();
}

class _UserProfileDisplayViewState extends State<UserProfileDisplayView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vm = Provider.of<UserProfileViewModel>(context, listen: false);
    await vm.loadProfile();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UserProfileViewModel>(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            //TODO: replace with real profile picture
            CircleAvatar(
              radius: 50,
              // backgroundImage: NetworkImage(""),
            ),

            const SizedBox(height: 10),

            Text(
              vm.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(Icons.cake, "Age", vm.age),
                  _buildStat(Icons.height, "Height", "${vm.height} cm"),
                  _buildStat(Icons.monitor_weight, "Weight", "${vm.weight} kg"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Medical Conditions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Medical Conditions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  vm.medicalConditions.isEmpty
                      ? const Text(
                        "No medical conditions",
                        style: TextStyle(color: Colors.grey),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            vm.medicalConditions
                                .split(',')
                                .map(
                                  (condition) => Chip(
                                    label: Text(condition.trim()),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                )
                                .toList(),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileView()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Edit Profile"),
      ),
    );
  }

  Widget _buildStat(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
