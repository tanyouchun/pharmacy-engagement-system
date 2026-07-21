import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import '../ai_analysis_sheet.dart';
import 'user_edit_profile_view.dart';
import '../../viewmodels/prescription_viewmodel.dart';

/// UserProfileDisplayView displays the user's healthcare profile information.
///
/// This page allows users to:
/// - View personal information.
/// - View health statistics.
/// - View allergies and medical conditions.
/// - Request AI-powered health profile analysis.
/// - Navigate to edit profile page.
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
      backgroundColor: const Color(0xFFF4F7FB),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// TOP HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 28, bottom: 16),

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
                  /// PROFILE IMAGE
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
                        Icons.person,
                        size: 42,
                        color: Color(0xFF4FC3CF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    userProfileViewModel.profile?.name ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    userProfileViewModel.profile?.gender ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.cake,
                      title: "Age",
                      value: userProfileViewModel.profile?.age.toString() ?? "",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.height,
                      title: "Height",
                      value: "${userProfileViewModel.profile?.height ?? ""} cm",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.monitor_weight,
                      title: "Weight",
                      value: "${userProfileViewModel.profile?.weight ?? ""} kg",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ALLERGIES SECTION
            _buildSectionCard(
              title: "Allergies",
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
              child:
                  userProfileViewModel.profile?.allergies.isEmpty ?? true
                      ? const Text(
                        "No allergies recorded",
                        style: TextStyle(color: Colors.grey),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            userProfileViewModel.profile!.allergies
                                .map(
                                  (allergy) => Chip(
                                    label: Text(allergy.trim()),
                                    backgroundColor: Colors.orange.shade50,
                                  ),
                                )
                                .toList(),
                      ),
            ),

            const SizedBox(height: 18),

            /// MEDICAL CONDITIONS
            _buildSectionCard(
              title: "Medical Conditions",
              icon: Icons.favorite,
              iconColor: Colors.redAccent,

              child:
                  (userProfileViewModel.profile?.medicalConditions.isEmpty ??
                          true)
                      ? const Text(
                        "No medical conditions",
                        style: TextStyle(color: Colors.grey),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            userProfileViewModel.profile!.medicalConditions
                                .map(
                                  (condition) => Chip(
                                    label: Text(condition),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                )
                                .toList(),
                      ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      /// Floating buttons:
      /// - AI Analysis button for generating AI health insights.
      /// - Edit Profile button for updating information.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            /// AI BUTTON (LEFT)
            FloatingActionButton.extended(
              heroTag: "ai",
              backgroundColor: const Color(0xFFDCC6FF),

              onPressed: () {
                _generateAIAnalysis(context);
              },

              icon: const Icon(Icons.smart_toy),
              label: const Text("AI Analysis"),
            ),

            /// EDIT BUTTON (RIGHT)
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
      ),
    );
  }

  /// Creates statistic card displaying health information.
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),

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
        children: [
          Icon(icon, color: const Color(0xFF4FC3CF)),

          const SizedBox(height: 8),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  /// Creates reusable information section card.
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),

                const SizedBox(width: 8),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    );
  }

  /// Opens AI analysis bottom sheet.
  ///
  /// Passes user health information and prescription history
  /// to AIAnalysisSheet for generating AI-based insights.
  void _generateAIAnalysis(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(
      context,
      listen: false,
    );

    final prescriptionViewModel = Provider.of<PrescriptionViewModel>(
      context,
      listen: false,
    );

    final profile = userProfileViewModel.profile;

    if (profile == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => AIAnalysisSheet(
            userId: "",

            name: profile.name,
            age: profile.age.toString(),
            gender: profile.gender,
            weight: profile.weight,
            height: profile.height,
            allergies: profile.allergies.join(", "),
            medicalConditions: profile.medicalConditions.join(", "),

            prescriptions: prescriptionViewModel.prescriptions,
          ),
    );
  }
}
