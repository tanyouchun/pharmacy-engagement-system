import 'package:flutter/material.dart';

class AdminManageConfigView extends StatefulWidget {
  const AdminManageConfigView({super.key});

  @override
  State<AdminManageConfigView> createState() => _AdminManageConfigViewState();
}

class _AdminManageConfigViewState extends State<AdminManageConfigView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Admin Manage Config View")),
    );
  }
}
