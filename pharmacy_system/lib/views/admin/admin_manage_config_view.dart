import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/admin_viewmodel.dart';

class AdminManageConfigView extends StatefulWidget {
  const AdminManageConfigView({super.key});

  @override
  State<AdminManageConfigView> createState() => _AdminManageConfigViewState();
}

class _AdminManageConfigViewState extends State<AdminManageConfigView> {
  Future<void> _toggleChatbot(BuildContext context, bool value) async {
    final adminManageConfigViewModel = Provider.of<AdminManageConfigViewModel>(
      context,
      listen: false,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Action"),
          content: Text(
            value
                ? "Are you sure you want to ENABLE the chatbot?"
                : "Are you sure you want to DISABLE the chatbot?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await adminManageConfigViewModel.updateChatbotStatus(value);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? "Chatbot has been enabled." : "Chatbot has been disabled.",
          ),
        ),
      );
    }
  }

  Future<void> _toggleAIAnalysis(BuildContext context, bool value) async {
    final adminManageConfigViewModel = Provider.of<AdminManageConfigViewModel>(
      context,
      listen: false,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Action"),
          content: Text(value ? "Enable AI Analysis?" : "Disable AI Analysis?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await adminManageConfigViewModel.updateAIAnalysisStatus(value);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? "AI Analysis enabled." : "AI Analysis disabled.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminManageConfigViewModel>(
      builder: (context, adminManageConfigViewModel, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// CHATBOT
                Card(
                  child: SwitchListTile(
                    title: const Text(
                      "Enable AI Chatbot",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      adminManageConfigViewModel.isChatbotEnabled
                          ? "Chatbot is currently ON"
                          : "Chatbot is currently OFF",
                    ),

                    value: adminManageConfigViewModel.isChatbotEnabled,

                    onChanged: (value) => _toggleChatbot(context, value),
                  ),
                ),

                const SizedBox(height: 16),

                /// AI ANALYSIS
                Card(
                  child: SwitchListTile(
                    title: const Text(
                      "Enable AI Analysis",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      adminManageConfigViewModel.isAIAnalysisEnabled
                          ? "AI Analysis is currently ON"
                          : "AI Analysis is currently OFF",
                    ),

                    value: adminManageConfigViewModel.isAIAnalysisEnabled,

                    onChanged: (value) => _toggleAIAnalysis(context, value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
