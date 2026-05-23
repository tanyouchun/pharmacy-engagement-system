import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class AdminManageConfigViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isChatbotEnabled = true;
  bool _isAIAnalysisEnabled = true;

  bool get isChatbotEnabled => _isChatbotEnabled;

  bool get isAIAnalysisEnabled => _isAIAnalysisEnabled;
  bool _disposed = false;

  StreamSubscription? _configSub;
  StreamSubscription? _authSub;

  AdminManageConfigViewModel() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        log("User logged out in AdminManageConfigViewModel → cancelling Firestore listener");
        _configSub?.cancel();
        _configSub = null;
        _isChatbotEnabled = true;
        _isAIAnalysisEnabled = true;
        if (!_disposed) {
          notifyListeners();
        }
      } else {
        log("User logged in in AdminManageConfigViewModel → starting Firestore listener");
        _listenToConfig();
      }
    });
  }

  void _listenToConfig() {
    _configSub?.cancel();

    _configSub = _firestore
        .collection("config")
        .doc("system")
        .snapshots()
        .listen((doc) {
          if (_disposed) return;

          if (doc.exists) {
            final data = doc.data();

            _isChatbotEnabled = data?["chatbotEnabled"] ?? true;
            _isAIAnalysisEnabled = data?["aiAnalysisEnabled"] ?? true;
          } else {
            _firestore.collection("config").doc("system").set({
              "chatbotEnabled": true,
              "aiAnalysisEnabled": true,
            });

            _isChatbotEnabled = true;
            _isAIAnalysisEnabled = true;
          }

          if (_disposed) return;
          notifyListeners();
        }, onError: (e) {
          log("Error listening to config: $e");
        });
  }

  Future<void> updateChatbotStatus(bool value) async {
    try {
      _isChatbotEnabled = value;
      log("Updating chatbot status to: $value");
      notifyListeners();

      await _firestore.collection("config").doc("system").set({
        "chatbotEnabled": value,
        "aiAnalysisEnabled": _isAIAnalysisEnabled,
      });
    } catch (e) {
      log("Error updating chatbot config: $e");
    }
  }

  Future<void> updateAIAnalysisStatus(bool value) async {
    try {
      _isAIAnalysisEnabled = value;
      log("Updating AI analysis status to: $value");
      notifyListeners();

      await _firestore.collection("config").doc("system").set({
        "chatbotEnabled": _isChatbotEnabled,
        "aiAnalysisEnabled": value,
      });
    } catch (e) {
      log("Error updating AI analysis config: $e");
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _configSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
