import 'package:flutter/material.dart';
import 'package:masjid_locator/src/services/auth_service.dart';

class MuadhinHomePage extends StatefulWidget {
  const MuadhinHomePage({super.key});

  @override
  _MuadhinHomePageState createState() => _MuadhinHomePageState();
}

class _MuadhinHomePageState extends State<MuadhinHomePage> {
  final AuthService _authService = AuthService();

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muadhin Home'),
        backgroundColor: const Color(0xFF2E2E2E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome Muadhin!',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 100.0), backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
