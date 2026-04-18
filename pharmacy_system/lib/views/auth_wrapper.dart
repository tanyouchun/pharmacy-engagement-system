import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'start_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        log(
          "AuthWrapper rebuilt -> ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, User: ${snapshot.data?.email}",
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          log("User is authenticated: ${snapshot.data?.email}");
          return const HomePage();
        }
        log("No authenticated user found");
        return const StartScreen();
      },
    );
  }
}
