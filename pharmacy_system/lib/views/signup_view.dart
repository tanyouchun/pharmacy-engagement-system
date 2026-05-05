import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../utils/custom_textfield.dart';
import 'login_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});
  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final signupViewModel = Provider.of<SignupViewModel>(context);

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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              CustomTextField(
                hint: "Enter your email",
                icon: Icons.email,
                controller: signupViewModel.emailController,
              ),

              const SizedBox(height: 15),

              CustomTextField(
                hint: "Enter your password",
                icon: Icons.lock,
                isPassword: true,
                controller: signupViewModel.passwordController,
              ),

              const SizedBox(height: 15),

              CustomTextField(
                hint: "Confirm your password",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: signupViewModel.confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != signupViewModel.passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ✅ NOW INSIDE COLUMN
              Row(
                children: [
                  const Text("Are you a pharmacist?"),
                  const SizedBox(width: 16),
                  Switch(
                    value: signupViewModel.isPharmacist,
                    onChanged: (val) {
                      signupViewModel.isPharmacist = val;
                      signupViewModel.notifyListeners();
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(signupViewModel.isPharmacist ? "Pharmacist" : "Regular user"),
                ],
              ),

              const Spacer(),

              signupViewModel.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signupViewModel.signup(context);
                        }
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                },
                child: const Text("Already have an account? Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
