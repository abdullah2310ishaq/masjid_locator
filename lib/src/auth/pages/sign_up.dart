import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masjid_locator/src/providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'user'; // Default role is 'user'
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Join us and find nearby mosques!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      validatorMessage: 'Please enter your name',
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      validatorMessage: 'Please enter a valid email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      validatorMessage:
                          'Please enter a password of at least 6 characters',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Role Selection - Toggle Buttons for better UX
                    const Text('Select Role',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ToggleButtons(
                      isSelected: [
                        _selectedRole == 'user',
                        _selectedRole == 'muadhin'
                      ],
                      onPressed: (int index) {
                        setState(() {
                          _selectedRole = index == 0 ? 'user' : 'muadhin';
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Regular User',
                              style: TextStyle(fontSize: 16)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child:
                              Text('Muadhin', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      borderColor: Colors.blue,
                      selectedBorderColor: Colors.blue,
                      fillColor: Colors.blue.withOpacity(0.2),
                      selectedColor: Colors.blue.shade800,
                    ),
                    const SizedBox(height: 40),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _signUpWithEmail(authProvider);
                              }
                            },
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Sign Up',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade800,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 100.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Show error if any
                    if (authProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          authProvider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Link to Login Page
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?",
                            style: TextStyle(fontSize: 16)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/login'); // Navigate to LoginPage
                          },
                          child: const Text('Log In',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Sign up with email and password
  void _signUpWithEmail(AuthProvider authProvider) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    authProvider.registerWithEmail(
        email, password, name, _selectedRole, context);
  }

  // Helper function to build text fields with validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String validatorMessage,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        if (labelText == 'Email' &&
            !RegExp(r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}
