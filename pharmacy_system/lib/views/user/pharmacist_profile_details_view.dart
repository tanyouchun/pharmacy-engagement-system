import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/pharmacist_profile_viewmodel.dart';
import '../../utils/report_client.dart';

/// Displays detailed information of a selected pharmacist.
///
/// This page is accessed by patients when viewing a pharmacist profile
/// before starting a chat or consultation.
///
/// Features:
/// - Displays pharmacist professional information.
/// - Shows license, experience, and active status.
/// - Allows users to report inappropriate pharmacist accounts.
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
    final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(
      context,
      listen: false,
    );

    await pharmacistProfileViewModel.loadPharmacistById(widget.pharmacistId);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pharmacistProfileViewModel = Provider.of<PharmacistProfileViewModel>(
      context,
    );

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
        // allow user to report Pharmacist to Admin
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                final pharmacistProfileViewModel =
                    Provider.of<PharmacistProfileViewModel>(
                      context,
                      listen: false,
                    );

                ReportClient.reportAccount(
                  context: context,
                  reportedUserId: widget.pharmacistId,
                  reportedName: pharmacistProfileViewModel.name,
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
        child: SingleChildScrollView(
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
                      child: const CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.local_pharmacy,
                          size: 42,
                          color: Color(0xFF4FC3CF),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// NAME
                    Text(
                      pharmacistProfileViewModel.name.isEmpty
                          ? "Pharmacist"
                          : pharmacistProfileViewModel.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      pharmacistProfileViewModel.pharmacyName.isEmpty
                          ? "Pharmacy"
                          : pharmacistProfileViewModel.pharmacyName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
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
                        value:
                            pharmacistProfileViewModel.license.isEmpty
                                ? "-"
                                : pharmacistProfileViewModel.license,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.work,
                        title: "Experience",
                        value:
                            pharmacistProfileViewModel.experience == 0
                                ? "-"
                                : "${pharmacistProfileViewModel.experience} yrs",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.verified,
                        title: "Status",
                        value: "Active",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ABOUT CARD
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
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: Color(0xFF4FC3CF)),
                          SizedBox(width: 8),
                          Text(
                            "About Pharmacist",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "${pharmacistProfileViewModel.name} is a licensed pharmacist "
                        "working at ${pharmacistProfileViewModel.pharmacyName} "
                        "with ${pharmacistProfileViewModel.experience} years of experience.",
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
    return scaffold;
  }

  /// Builds reusable statistic card component.
  ///
  /// Used to display pharmacist information such as
  /// license number, experience, and account status.
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
