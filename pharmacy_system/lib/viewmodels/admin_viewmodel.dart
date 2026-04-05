import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/account_issue.dart';

class AdminManageUserViewModel extends ChangeNotifier {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  List<QueryDocumentSnapshot> _users = [];
  List<AccountIssueReport> _reports = [];
  List<AccountIssueReport> get reports => _reports;

  bool _isLoadingReports = true;
  bool get isLoadingReports => _isLoadingReports;
  bool _isLoading = true;
  String? _reportError;
  String? get reportError => _reportError;

  String? _userError;
  String? get userError => _userError;

  List<QueryDocumentSnapshot> get users => _users;
  bool get isLoading => _isLoading;

  Future<bool> submitReport({
    required String reportedUserId,
    required String reportedName,
    required String reportedRole,
    required String? reportedBy,
    required String reason,
  }) async {
    if (reason.trim().length < 5) {
      _reportError = "Reason too short";
      notifyListeners();
      return false;
    }

    try {
      final data = AccountIssueReport(
        reportedUserId: reportedUserId,
        reportedName: reportedName,
        reportedRole: reportedRole,
        reportedBy: reportedBy,
        reason: reason,
        status: "pending",
      );
      await FirebaseFirestore.instance
          .collection('account_issues')
          .add(data.toMap());
      log("Suspended user account: ${data.toMap()}");
      return true;
    } catch (e) {
      _reportError = e.toString();
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
        _userError = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void listenToReports() {
    FirebaseFirestore.instance
        .collection('account_issues')
        // .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (snapshot) {
            _reports =
                snapshot.docs
                    .map((doc) => AccountIssueReport.fromDoc(doc))
                    .toList();
            log("Loaded ${_reports.length} reports");
            _isLoadingReports = false;
            notifyListeners();
          },
          onError: (e) {
            _reportError = e.toString();
            log(_reportError!);
            _isLoadingReports = false;
            notifyListeners();
          },
        );
  }

  Future<void> setStatus(String reportId) async {
    try {
      await FirebaseFirestore.instance
          .collection('account_issues')
          .doc(reportId)
          .update({"status": "resolved"});
    } catch (e) {
      _reportError = e.toString();
      notifyListeners();
    }
  }

  Future<void> blockAccount(
    String uid, {
    Duration? duration,
    bool permanent = false,
  }) async {
    try {
      DateTime? suspendUntil;

      if (!permanent && duration != null) {
        suspendUntil = DateTime.now().add(duration);
      }

      await _usersRef.doc(uid).update({
        "isBlocked": true,
        "suspendUntil": permanent ? null : suspendUntil,
        "isPermanentBan": permanent,
      });
    } catch (e) {
      _userError = e.toString();
      notifyListeners();
    }
  }

  Future<void> unBlockAccount(String uid) async {
    try {
      await _usersRef.doc(uid).update({
        "isBlocked": false,
        "suspendUntil": null,
        "isPermanentBan": false,
      });
    } catch (e) {
      _userError = e.toString();
      notifyListeners();
    }
  }

  Map<String, dynamic>? getUserData(String uid) {
    try {
      return _users.firstWhere((u) => u.id == uid).data()
          as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
