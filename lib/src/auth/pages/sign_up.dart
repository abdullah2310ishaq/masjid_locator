import 'package:flutter/material.dart';
import 'package:masjid_locator/src/auth/pages/otp_screen.dart';
import 'package:masjid_locator/src/widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'user'; // Default role is 'user'

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
                'Create an Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Full Name Input
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Name',
                keyboardType: TextInputType.name,
                labelColor: Colors.blue,
              ),
              const SizedBox(height: 20),

              // Phone Number Input
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
                labelColor: Colors.blue,
              ),
              const SizedBox(height: 20),

              // Password Input
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                labelColor: Colors.blue,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 20),

              // Role Selection (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Regular User')),
                  DropdownMenuItem(value: 'muadhin', child: Text('Muadhin')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Send OTP Button
              ElevatedButton(
                onPressed: _sendOTP,
                child: const Text('Send OTP'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 100.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to send OTP
  void _sendOTP() {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isNotEmpty && phone.isNotEmpty && password.isNotEmpty) {
      // Navigate to the OTP Screen with the user details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            phoneNumber: phone,
            name: name,
            password: password,
            role: _selectedRole,
          ),
        ),
      );
    } else {
      _showSnackbar(context, 'Please fill out all fields.');
    }
  }

  // Display SnackBar
  void _showSnackbar(BuildContext context, String message) {
    final snackBar =
        SnackBar(content: Text(message), backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
