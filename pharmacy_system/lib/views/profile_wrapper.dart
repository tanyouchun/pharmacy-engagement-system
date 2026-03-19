import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'profile.dart';
import 'create_profile_view.dart';

class ProfileWrapper extends StatelessWidget {
  const ProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProfileViewModel>(context);

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
        ? const ProfileDisplayView()
        : const ProfileView();
  }
}