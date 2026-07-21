import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../utils/custom_textfield.dart';
import 'login_view.dart';

/// Registration screen that allows new users to create
/// either a customer or pharmacist account.
class SignupView extends StatefulWidget {
  const SignupView({super.key});
  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Register a listener to evaluate password strength
    // whenever the password field changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signupViewModel = Provider.of<SignupViewModel>(
        context,
        listen: false,
      );

      signupViewModel.passwordController.addListener(() {
        signupViewModel.checkPasswordStrength(
          signupViewModel.passwordController.text,
        );
      });
    });
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
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

                const SizedBox(height: 5),

                if (signupViewModel.passwordStrength.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password Strength: ${signupViewModel.passwordStrength}",
                        style: TextStyle(
                          color: signupViewModel.passwordStrengthColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                CustomTextField(
                  hint: "Confirm your password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: signupViewModel.confirmPasswordController,
                ),

                const SizedBox(height: 20),

                if (signupViewModel.errors.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: Colors.red.shade700, width: 5),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                      ),
                      title: const Text(
                        "Unable to create account",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            signupViewModel.errors.values
                                .map((e) => Text("• $e"))
                                .toList(),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Allow the user to choose whether
                // to register as a pharmacist or regular user.
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
                    Text(
                      signupViewModel.isPharmacist
                          ? "Pharmacist"
                          : "Regular user",
                    ),
                  ],
                ),

                const SizedBox(height: 40),

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
                          signupViewModel.signup(context);
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
      ),
    );
  }
}
