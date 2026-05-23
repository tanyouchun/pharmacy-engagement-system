import 'package:cloud_firestore/cloud_firestore.dart';
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

  AdminManageConfigViewModel() {
    _listenToConfig();
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
        });
  }

  Future<void> updateChatbotStatus(bool value) async {
    try {
      _isChatbotEnabled = value;

      notifyListeners();

      await _firestore.collection("config").doc("system").set({
        "chatbotEnabled": value,
        "aiAnalysisEnabled": _isAIAnalysisEnabled,
      });
    } catch (e) {
      debugPrint("Error updating chatbot config: $e");
    }
  }

  Future<void> updateAIAnalysisStatus(bool value) async {
    try {
      _isAIAnalysisEnabled = value;

      notifyListeners();

      await _firestore.collection("config").doc("system").set({
        "chatbotEnabled": _isChatbotEnabled,
        "aiAnalysisEnabled": value,
      });
    } catch (e) {
      debugPrint("Error updating AI analysis config: $e");
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _configSub?.cancel();
    super.dispose();
  }
}
