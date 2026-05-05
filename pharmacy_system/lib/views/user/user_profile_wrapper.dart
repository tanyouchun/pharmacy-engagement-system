import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import 'user_profile_display_view.dart';
import 'user_create_profile_view.dart';

class UserProfileWrapper extends StatefulWidget {
  const UserProfileWrapper({super.key});

  @override
  State<UserProfileWrapper> createState() => _UserProfileWrapperState();
}

class _UserProfileWrapperState extends State<UserProfileWrapper> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProfileViewModel>().checkProfileExists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = context.watch<UserProfileViewModel>();

    if (userProfileViewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return userProfileViewModel.hasProfile
        ? const UserProfileDisplayView()
        : const ProfileView();
  }
}
