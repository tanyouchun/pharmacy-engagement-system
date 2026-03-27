import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import 'user_profile_display_view.dart';
import 'user_create_profile_view.dart';

class UserProfileWrapper extends StatelessWidget {
  const UserProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

    // first time load
    if (!userProfileViewModel.hasProfile && !userProfileViewModel.isLoading) {
      userProfileViewModel.checkProfileExists();
    }

    if (userProfileViewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return userProfileViewModel.hasProfile
        ? const UserProfileDisplayView()
        : const ProfileView();
  }
}