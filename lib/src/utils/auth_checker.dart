import 'package:flutter/material.dart';
import 'package:masjid_locator/src/auth/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:masjid_locator/src/providers/auth_provider.dart';
import 'package:masjid_locator/src/screens/muazzins/masjid_rep_home_page.dart';
import 'package:masjid_locator/src/screens/users/user_home_page.dart';

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading screen while checking authentication state
    if (authProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If user is authenticated, navigate based on their role
    if (authProvider.user != null) {
      if (authProvider.role == 'muadhin') {
        return MuadhinHomePage();  // Muadhin Home
      } else if (authProvider.role == 'user') {
        return UserHomePage();  // Regular User Home
      }
    }

    // If user is not authenticated, show login screen
    return  LoginPage();
  }
}
