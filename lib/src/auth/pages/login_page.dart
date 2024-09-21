import 'package:flutter/material.dart';
import 'package:masjid_locator/src/auth/pages/otp_screen.dart';
import 'package:masjid_locator/src/auth/pages/sign_up.dart'; // Import the SignUpPage
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

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
                'Login with OTP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number Field
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone, 
                labelColor: Colors.blue,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _sendOTP,
                child: _isLoading ? CircularProgressIndicator() : Text('Send OTP'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 100.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Link to Sign Up Page
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
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

  // Send OTP to user's phone number
  void _sendOTP() async {
    String phone = _phoneController.text.trim();

    if (phone.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.sendOTP(phone, (verificationId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: phone,
                name: '',
                password: '', // For login, we do not need the name and password
                role: '', // Role is not needed for login
                // verificationId: verificationId, // Pass verification ID
              ),
            ),
          );
        });
      } catch (e) {
        _showSnackbar('Failed to send OTP: ${e.toString()}');
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      _showSnackbar('Please enter a valid phone number.');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
