import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masjid_locator/src/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please log in to continue',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
                      validatorMessage: 'Please enter your password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),

                    // Login Button
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _loginWithEmail(authProvider);
                              }
                            },
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login',
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

                    // Redirect to SignUp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",
                            style: TextStyle(fontSize: 16)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/signUp'); // Navigate to SignUpPage
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
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

  // Login with email and password
  void _loginWithEmail(AuthProvider authProvider) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      authProvider.loginWithEmail(email, password, context);
    } else {
      _showErrorSnackbar('Please fill out both fields');
    }
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

  // Display error snackbar
  void _showErrorSnackbar(String message) {
    final snackBar =
        SnackBar(content: Text(message), backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
