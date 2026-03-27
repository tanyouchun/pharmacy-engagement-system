import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/pharmacist_profile_viewmodel.dart';
import '../../utils/report_helper.dart';

class PharmacistProfileDetailsView extends StatefulWidget {
  final String pharmacistId;

  const PharmacistProfileDetailsView({super.key, required this.pharmacistId});

  @override
  State<PharmacistProfileDetailsView> createState() =>
      _PharmacistProfileDetailsViewState();
}

class _PharmacistProfileDetailsViewState
    extends State<PharmacistProfileDetailsView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(context, listen: false);

    await pharmacistProfileViewModel.loadPharmacistById(widget.pharmacistId);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!pharmacistProfileViewModel.hasProfile) {
      return const Scaffold(
        body: Center(child: Text("Pharmacist profile not found")),
      );
    }

    var scaffold = Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacist Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                final vm = Provider.of<PharmacistProfileViewModel>(
                  context,
                  listen: false,
                );

                ReportHelper.showReportDialog(
                  context: context,
                  reportedUserId: widget.pharmacistId,
                  reportedName: vm.name,
                  reportedRole: "pharmacist",
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'report', child: Text("Report")),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"),
            ),

            const SizedBox(height: 10),

            // Name
            Text(
              pharmacistProfileViewModel.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 📊 Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(Icons.badge, "License", pharmacistProfileViewModel.license),
                  _buildStat(Icons.local_pharmacy, "Pharmacy", pharmacistProfileViewModel.pharmacyName),
                  _buildStat(Icons.work, "Experience", "${pharmacistProfileViewModel.experience} yrs"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 📝 Extra Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "About Pharmacist",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "${pharmacistProfileViewModel.name} is a licensed pharmacist working at ${pharmacistProfileViewModel.pharmacyName} with ${pharmacistProfileViewModel.experience} years of experience.",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return scaffold;
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
