import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import 'user_profile_display_view.dart';
import 'user_create_profile_view.dart';

class UserProfileWrapper extends StatelessWidget {
  const UserProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UserProfileViewModel>(context);

    // first time load
    if (!vm.hasProfile && !vm.isLoading) {
      vm.checkProfileExists();
    }

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return vm.hasProfile
        ? const UserProfileDisplayView()
        : const ProfileView();
  }
}