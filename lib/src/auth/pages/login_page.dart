import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/auth/pages/sign_up.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Login to continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // Custom Text Fields for Email and Password
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 40),

              // Login Button
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 100.0),
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.black, width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

void _login() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();
  if (email.isNotEmpty && password.isNotEmpty) {
    User? user = await _authService.loginWithEmail(email, password);
    if (user != null) {
      // Fetch the user's role from Firestore
      DocumentSnapshot? userDoc = await _authService.getUserData(user.uid);
      if (userDoc != null) {
        String role = userDoc['role'];

        // Show a snackbar for successful login
        _showSnackbar(context, 'Logged in as ${user.email}');

        // Route based on the user's role
        if (role == 'muadhin') {
          Navigator.pushReplacementNamed(context, '/muadhinHome');
        } else {
          Navigator.pushReplacementNamed(context, '/userHome');
        }
      } else {
        _showSnackbar(context, 'Failed to fetch user role.');
      }
    } else {
      _showSnackbar(context, 'Login failed. Check credentials.');
    }
  }
}


  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
