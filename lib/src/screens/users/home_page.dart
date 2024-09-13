import 'package:flutter/material.dart';
import 'package:masjid_locator/src/services/auth_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final AuthService _authService = AuthService(); // Instantiate AuthService

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate back to login after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Masjid Locator!',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed:
                  _logout, // Call the logout method when the button is pressed
              child: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 100.0),
                backgroundColor: Colors.transparent,
                side: const BorderSide(
                    color: Colors.black, width: 1.0), // Simple black border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Text color black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
