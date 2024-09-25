import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/models/user_model.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String password;
  final String role;

  OTPScreen({required this.phoneNumber, required this.name, required this.password, required this.role});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  // Send OTP
  void _sendOTP() {
    _authService.sendOTP(widget.phoneNumber, (verificationId) {
      setState(() {
        _verificationId = verificationId;
      });
    });
  }

  // Verify OTP and Register User
  void _verifyOTP() async {
    String otp = _otpController.text.trim();
    if (_verificationId != null && otp.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      User? user = await _authService.verifyOTP(_verificationId!, otp);
      if (user != null) {
        UserModel newUser = UserModel(
          id: user.uid,
          name: widget.name,
          phoneNumber: widget.phoneNumber,
          role: widget.role,
          password: widget.password,
        );
        await _authService.registerUser(newUser);

        Navigator.pushReplacementNamed(context, widget.role == 'muadhin' ? '/muadhinHome' : '/userHome');
      } else {
        _showSnackbar('Invalid OTP');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please enter the OTP sent to your phone',
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // OTP Input
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Verify OTP Button
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              child: _isLoading ? CircularProgressIndicator() : Text('Verify OTP'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
