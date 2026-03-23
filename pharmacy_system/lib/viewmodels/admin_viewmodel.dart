import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharmacy_system/viewmodels/pharmacist_profile_viewmodel.dart';

class AdminManageUserViewModel extends ChangeNotifier {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  List<QueryDocumentSnapshot> _users = [];
  bool _isLoading = true;
  String? _error;

  List<QueryDocumentSnapshot> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> submitReport({
    required String reportedUserId,
    required String reportedName,
    required String reportedRole,
    required String? reportedBy,
    required String reason,
  }) async {
    if (reason.trim().length < 5) {
      _error = "Reason too short";
      notifyListeners();
      return false;
    }

    try {
      await FirebaseFirestore.instance.collection('account_issues').add({
        "reportedUserId": reportedUserId,
        "reportedName": reportedName,
        "reportedRole": reportedRole,
        "reportedBy": reportedBy,
        "reason": reason,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void listenToUsers() {
    _usersRef.snapshots().listen(
      (snapshot) {
        _users = snapshot.docs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 🔹 Block / Unblock
  Future<void> toggleBlock(String uid, bool currentStatus) async {
    try {
      await _usersRef.doc(uid).update({"isBlocked": !currentStatus});
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
