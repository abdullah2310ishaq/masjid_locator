import 'package:flutter/material.dart';
import 'package:masjid_locator/src/services/auth_service.dart';

class MuadhinHomePage extends StatefulWidget {
  const MuadhinHomePage({super.key});

  @override
  State<MuadhinHomePage> createState() => _MuadhinHomePageState();
}

class _MuadhinHomePageState extends State<MuadhinHomePage> {
  // authprize krna ha
  final AuthService _authService = AuthService(); 

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(
        context, '/login'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muadhin Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome Muadhin!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _logout, 
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
