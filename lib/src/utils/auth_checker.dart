import 'package:flutter/material.dart';
import 'package:masjid_locator/src/screens/muazzins/muaddhin_page.dart';
import 'package:masjid_locator/src/screens/users/home_page.dart';

import 'package:provider/provider.dart';
import 'package:masjid_locator/src/providers/auth_provider.dart';

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return const CircularProgressIndicator();  // Show loading while checking authentication
    } else if (authProvider.role == 'muadhin') {
      return const MuadhinHomePage();  // Navigate to Muadhin Home
    } else if (authProvider.role == 'user') {
      return const UserHomePage();  // Navigate to User Home
    } else {
      return const CircularProgressIndicator();  // Fallback for other cases
    }
  }
}
