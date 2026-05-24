import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:pharmacy_system/viewmodels/chat_viewmodel.dart';
import 'package:pharmacy_system/views/admin/admin_manage_config_view.dart';
import 'package:pharmacy_system/views/admin/admin_manage_user_view.dart';
import 'package:pharmacy_system/views/user/user_prescription_view.dart';
import 'package:pharmacy_system/services/auth_service.dart';
import 'user/user_profile_wrapper.dart';
import 'chatbot_view.dart';
import 'auth_wrapper.dart';
import 'pharmacist/pharmacist_profile_wrapper.dart';
import 'user/user_chat_list_view.dart';
import 'pharmacist/pharmacist_chat_list_view.dart';
import 'user/user_reminder_view.dart';
import 'pharmacist/pharmacist_pending_approval_view.dart';
import 'admin/admin_pharmacist_approval_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _role;
  bool _isLoadingRole = true;
  final AuthService _authService = AuthService();
  String? _approvalStatus;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _role = null;
        _isLoadingRole = false;
      });
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (!mounted) return;
      setState(() {
        _role = doc.data()?['role'] as String?;
        _approvalStatus = doc.data()?['approvalStatus'] as String?;
        _isLoadingRole = false;
      });
    } catch (e) {
      if (!mounted) return;
      log("Failed to load user role for ${user.uid}: $e");
      setState(() {
        _role = null;
        _isLoadingRole = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final chatViewModel = context.read<ChatViewModel>();
      chatViewModel.disposeListener();

      _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  String get _title {
    if (_role == 'admin') {
      final titles = [
        "Home",
        "Manage User",
        "Pharmacists Approval",
        "AI Assistant",
        "Manage Chatbot Configuration",
      ];
      return (_currentIndex < titles.length) ? titles[_currentIndex] : "Home";
    }
    final titles =
        _role == 'pharmacist'
            ? ["Home", "Chat", "Chatbot", "Profile"]
            : ["Home", "Chat", "AI Assistant", "Prescription", "Profile"];

    return (_currentIndex < titles.length) ? titles[_currentIndex] : "Home";
  }

  List<Widget> get _pages {
    // Shared first, second and fourth tabs
    final home = ReminderHomeView(
      role: _role,
      onOpenChatbot: () {
        setState(() {
          _currentIndex = 2; // switch to chatbot tab
        });
      },
    );
    final chat =
        _role == 'pharmacist'
            ? const PharmacistChatListView()
            : const ChatListView();
    final profile =
        _role == 'pharmacist'
            ? const PharmacistProfileWrapper()
            : const UserProfileWrapper();

    if (_role == 'pharmacist') {
      return [home, chat, const ChatbotView(), profile];
    } else if (_role == 'admin') {
      return [
        home,
        const AdminManageUserView(),
        const AdminPharmacistApprovalView(),
        const ChatbotView(),
        const AdminManageConfigView(),
      ];
    }
    return [home, chat, const ChatbotView(), const PrescriptionPage(), profile];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_role == 'pharmacist' &&
        (_approvalStatus == 'pending' || _approvalStatus == 'rejected')) {
      return PharmacistPendingApprovalView(
        approvalStatus: _approvalStatus ?? 'pending',
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),

        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.withOpacity(0.15)),
        ),
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items:
                _role == 'admin'
                    ? [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: "Home",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.group_outlined),
                        label: "Manage User",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.approval),
                        label: "Pharmacists",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.smart_toy, size: 30),
                        label: "AI",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.settings_outlined),
                        label: "Manage Config",
                      ),
                    ]
                    : _role == 'pharmacist'
                    ? [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: "Home",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.chat_bubble_outline),
                        label: "Chat",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.smart_toy, size: 30),
                        label: "AI",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        label: "Profile",
                      ),
                    ]
                    : [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: "Home",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.chat_bubble_outline),
                        label: "Chat",
                      ),

                      /// 🤖 AI CENTER
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.smart_toy, size: 30),
                        label: "AI",
                      ),

                      const BottomNavigationBarItem(
                        icon: Icon(Icons.medication_outlined),
                        label: "Prescription",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        label: "Profile",
                      ),
                    ],
          ),
        ),
      ),
    );
  }
}
