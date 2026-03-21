import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/signup_viewmodel.dart';
import 'viewmodels/user_profile_viewmodel.dart';
import 'viewmodels/prescription_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/reminder_viewmodel.dart';
import 'views/auth_wrapper.dart';
import 'views/pharmacist/pharmacist_profile_Form_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => UserProfileViewModel()),
        ChangeNotifierProvider(create: (_) => PrescriptionViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => ReminderViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/pharmacistProfile': (context) => const PharmacistProfileFormView(),
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

