import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharmacy_system/views/user/user_prescription_view.dart';
import 'package:pharmacy_system/services/auth_service.dart';
import 'user/user_profile_wrapper.dart';
import 'pharmacist/pharmacist_chatbot_view.dart';
import 'auth_wrapper.dart';
import 'pharmacist/pharmacist_profile_wrapper.dart';
import 'user/user_chat_list_view.dart';
import 'pharmacist/pharmacist_chat_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _role;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }


  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _role = null;
        _isLoadingRole = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _role = doc.data()?['role'] as String?;
        _isLoadingRole = false;
      });
    } catch (_) {
      setState(() {
        _role = null;
        _isLoadingRole = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  String get _title {
    switch (_currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Chat";
      case 2:
        // For pharmacists, show chatbot instead of prescription
        if (_role == 'pharmacist') {
          return "Chatbot";
        }
        return "Prescription";
      case 3:
        return "Profile";
      default:
        return "Home";
    }
  }

  List<Widget> get _pages {
    // Shared first, second and fourth tabs
    final home = const Center(child: Text("Home Page"));
    final chat = _role == 'pharmacist'
    ? const PharmacistChatListView()
    : const ChatListView();
    final profile =
        _role == 'pharmacist' ? const PharmacistProfileWrapper() : const UserProfileWrapper();

    if (_role == 'pharmacist') {
      return [
        home,
        chat,
        const PharmacistChatbotView(),
        profile,
      ];
    }

    return [
      home,
      chat,
      const PrescriptionPage(),
      profile,
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
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
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "Home"),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _role == 'pharmacist'
                      ? Icons.smart_toy_outlined
                      : Icons.medication_outlined,
                ),
                label: _role == 'pharmacist' ? "Chatbot" : "Prescription",
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
