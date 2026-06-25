import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../viewmodels/login_viewmodel.dart';
import '../utils/custom_textfield.dart';
import 'signup_view.dart';
import 'user/user_create_profile_view.dart';
import 'pharmacist/pharmacist_profile_Form_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign In",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
                CustomTextField(
                  hint: "Enter your email",
                  icon: Icons.email_outlined,
                  controller: loginViewModel.emailController,
                ),
                const SizedBox(height: 15),

                // Password
                CustomTextField(
                  hint: "Enter your password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: loginViewModel.passwordController,
                ),

                const SizedBox(height: 10),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Forgot password?"),
                  ),
                ),

                const SizedBox(height: 10),

                if (loginViewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Center(
                      child: Text(
                        loginViewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                // Sign In butto
                loginViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed:
                          loginViewModel.isLoading
                              ? null
                              : () async {
                                await loginViewModel.login();
                                if (context.mounted &&
                                    loginViewModel.errorMessage == null) {
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                }

                                // if (FirebaseAuth.instance.currentUser != null) {
                                //   Navigator.of(context).pushAndRemoveUntil(
                                //     MaterialPageRoute(
                                //       builder: (_) => const AuthWrapper(),
                                //     ),
                                //     (route) => false,
                                //   );
                                // }
                              },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                const SizedBox(height: 20),

                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupView()),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // OR Divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔵 GOOGLE BUTTON (MATCHED UI)
                _socialButton(
                  icon: "assets/images/google.png",
                  text: "Sign in with Google",
                  onTap: () async {
                    final result = await loginViewModel.signInWithGoogle();

                    if (!context.mounted) return;

                    if (result == "NEW_GOOGLE_USER") {
                      _showRoleSelectionDialog(context);
                      return;
                    }

                    if (loginViewModel.errorMessage == null) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showRoleSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Text("Choose Account Type", textAlign: TextAlign.center),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select how you want to use the app.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text("Normal User"),
                onPressed: () async {
                  await _createGoogleUser(role: "user");

                  if (context.mounted) {
                    Navigator.pop(context);

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const ProfileView()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_pharmacy),
                label: const Text("Pharmacist"),
                onPressed: () async {
                  await _createGoogleUser(role: "pharmacist");

                  if (context.mounted) {
                    Navigator.pop(context);

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const PharmacistProfileFormView(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _createGoogleUser({required String role}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    "email": user.email ?? "",
    "name": user.displayName ?? "",
    "role": role,
    "createdAt": FieldValue.serverTimestamp(),
    "isBlocked": false,
    "suspendUntil": null,
    "reportCount": 0,
    "isPermanentBan": false,
  });
}

Widget _socialButton({
  required String icon,
  required String text,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Ink(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Image.asset(icon, height: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Center(
              child: Text(text, style: const TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 40), // balance spacing
        ],
      ),
    ),
  );
}
