import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../widgets/custom_textfield.dart';
import 'login_view.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SignupViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter your email",
              icon: Icons.email,
              controller: vm.emailController,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              hint: "Enter your password",
              icon: Icons.lock,
              isPassword: true,
              controller: vm.passwordController,
            ),

            const SizedBox(height: 20),

            // Role selection: Pharmacist or regular user
            Row(
              children: [
                const Text(
                  "Are you a pharmacist?",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: vm.isPharmacist,
                  onChanged: (val) {
                    vm.isPharmacist = val;
                    // vm.notifyListeners();
                  },
                  activeColor: Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  vm.isPharmacist ? "Pharmacist" : "Regular user",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const Spacer(),
            // Sign Up Button
            vm.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => vm.signup(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

            const SizedBox(height: 20),

            // Sign In Text
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    children: [
                      TextSpan(
                        text: "Sign In",
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
