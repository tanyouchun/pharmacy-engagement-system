import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/user_profile_viewmodel.dart';
import '../../viewmodels/admin_config_viewmodel.dart';
import '../../models/prescription.dart';

class AIAnalysisSheet extends StatefulWidget {
  final String userId;

  final String name;
  final String age;
  final String gender;
  final String weight;
  final String height;
  final String allergies;
  final String medicalConditions;

  final List prescriptions;

  const AIAnalysisSheet({
    super.key,
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.allergies,
    required this.medicalConditions,
    required this.prescriptions,
  });

  @override
  State<AIAnalysisSheet> createState() => _AIAnalysisSheetState();
}

class _AIAnalysisSheetState extends State<AIAnalysisSheet> {
  bool isLoading = false;
  bool hasStarted = false;

  String analysis = "";

  Future<void> _loadAnalysis() async {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(
      context,
      listen: false,
    );

    setState(() {
      hasStarted = true;
      isLoading = true;
    });

    try {
      final result = await userProfileViewModel.generateAIAnalysis(
        name: widget.name,
        age: widget.age,
        gender: widget.gender,
        weight: widget.weight,
        height: widget.height,
        allergies: widget.allergies,
        medicalConditions: widget.medicalConditions,
        prescriptions: List<Prescription>.from(widget.prescriptions),
      );

      setState(() {
        analysis = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        analysis = "Failed to generate AI analysis.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminConfigViewModel = Provider.of<AdminManageConfigViewModel>(
      context,
    );

    final isAIAnalysisEnabled = adminConfigViewModel.isAIAnalysisEnabled;
    final hasInsufficientData = widget.prescriptions.isEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP BAR
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Text(
                    "AI Medication Analysis",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "AI reviews your medication history and profile trends.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(20),
                ),

                child:
                    !isAIAnalysisEnabled
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block,
                                size: 70,
                                color: Colors.red.shade200,
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "AI Analysis Unavailable",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "AI Analysis is currently unavailable, please try again later.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        )
                        : hasInsufficientData
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 70,
                                color: Colors.orange.shade200,
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Insufficient Data",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "AI Analysis requires visible prescription history to generate analysis.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        )
                        : !hasStarted
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 70,
                                color: Colors.deepPurple.shade200,
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Generate AI Analysis",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "AI will analyze medication trends,\nrisk factors and recommendations,\nbased on your profile and prescription history.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 30),

                              ElevatedButton.icon(
                                onPressed: _loadAnalysis,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE9D5FF),
                                  foregroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                icon: const Icon(Icons.smart_toy),

                                label: const Text(
                                  "Start Analysis",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                        : isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          child: Text(
                            analysis,
                            style: const TextStyle(fontSize: 15, height: 1.6),
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                icon: const Icon(Icons.check, color: Colors.white),

                label: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
