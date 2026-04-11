import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pharmacist_profile_display_view.dart';
import 'pharmacist_profile_Form_view.dart';
import '../../viewmodels/pharmacist_profile_viewmodel.dart';

class PharmacistProfileWrapper extends StatelessWidget {
  const PharmacistProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PharmacistProfileViewModel()..checkProfileExists(),
      child: Consumer<PharmacistProfileViewModel>(
        builder: (context, pharmacistProfileViewModel, _) {
          if (pharmacistProfileViewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return pharmacistProfileViewModel.hasProfile
              ? const PharmacistProfileDisplayView()
              : const PharmacistProfileFormView();
        },
      ),
    );
  }
}

