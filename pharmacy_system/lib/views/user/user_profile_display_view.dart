import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import '../ai_analysis_sheet.dart';
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
    final userProfileViewModel = Provider.of<UserProfileViewModel>(
      context,
      listen: false,
    );
    await userProfileViewModel.loadProfile();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

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
              userProfileViewModel.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(Icons.cake, "Age", userProfileViewModel.age),
                  _buildStat(
                    Icons.height,
                    "Height",
                    "${userProfileViewModel.height} cm",
                  ),
                  _buildStat(
                    Icons.monitor_weight,
                    "Weight",
                    "${userProfileViewModel.weight} kg",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Medical Conditions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Medical Conditions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  userProfileViewModel.medicalConditions.isEmpty
                      ? const Text(
                        "No medical conditions",
                        style: TextStyle(color: Colors.grey),
                      )
                      : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            userProfileViewModel.medicalConditions
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

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: FloatingActionButton.extended(
              heroTag: "ai",
              backgroundColor: const Color(0xFFDCC6FF),
              onPressed: () {
                _generateAIAnalysis(context);
              },
              icon: const Icon(Icons.smart_toy),
              label: const Text("AI Analysis"),
            ),
          ),

          FloatingActionButton.extended(
            heroTag: "edit",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileView()),
              );
            },
            backgroundColor: const Color(0xFF4FC3CF),
            foregroundColor: Colors.black,
            icon: const Icon(Icons.edit),
            label: const Text("Edit Profile"),
          ),
        ],
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

  void _generateAIAnalysis(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AIAnalysisSheet(),
  );
}
}
