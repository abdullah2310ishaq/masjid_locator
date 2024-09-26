import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/services/auth_service.dart';

class MuadhinHomePage extends StatefulWidget {
  const MuadhinHomePage({super.key});

  @override
  _MuadhinHomePageState createState() => _MuadhinHomePageState();
}

class _MuadhinHomePageState extends State<MuadhinHomePage> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? muadhinName = "Muadhin";

  @override
  void initState() {
    super.initState();
    _fetchMuadhinName(); // Fetch Muadhin name on page load
  }

  // Fetch Muadhin name from Firebase
  Future<void> _fetchMuadhinName() async {
    User? currentUser = _auth.currentUser;
    setState(() {
      muadhinName = currentUser?.displayName ??
          "Muadhin"; // Set the name from Firebase, default is "Muadhin"
    });
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muadhin Home'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(), // Display Welcome message
          ],
        ),
      ),
    );
  }

  // Welcome Card with Muadhin's Name
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $muadhinName!',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is your mosque representative page.',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
