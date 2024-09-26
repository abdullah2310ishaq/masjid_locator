// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:masjid_locator/src/auth/pages/login_page.dart';
// import 'package:masjid_locator/src/models/user_model.dart';
// import 'package:masjid_locator/src/services/auth_service.dart';

// class OTPScreen extends StatefulWidget {
//   final String phoneNumber;
//   final String name;
//   final String password;
//   final String role;

//   OTPScreen({
//     required this.phoneNumber,
//     required this.name,
//     required this.password,
//     required this.role,
//   });

//   @override
//   _OTPScreenState createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   final AuthService _authService = AuthService();
//   late List<TextEditingController> _otpControllers;
//   late List<FocusNode> _focusNodes;
//   String? _verificationId;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _otpControllers = List.generate(6, (_) => TextEditingController());
//     _focusNodes = List.generate(6, (_) => FocusNode());
//     _sendOTP();
//   }

//   @override
//   void dispose() {
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }

//   // Send OTP
//   void _sendOTP() {
//     _authService.sendOTP(widget.phoneNumber, (verificationId) {
//       setState(() {
//         _verificationId = verificationId;
//       });
//     });
//   }

//   // Verify OTP
//   void _verifyOTP() async {
//     String otp = _otpControllers.map((controller) => controller.text).join();
//     if (_verificationId != null && otp.length == 6) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         User? user = await _authService.verifyOTP(_verificationId!, otp);
//         if (user != null) {
//           // Hash the password here before registering the user in Firestore
//           String hashedPassword = hashPassword(widget.password);

//           // Register the user in Firestore
//           UserModel newUser = UserModel(
//             id: user.uid,
//             name: widget.name,
//             phoneNumber: widget.phoneNumber,
//             role: widget.role,
//             password: hashedPassword, // Storing hashed password
//           );
//           await _authService.registerUser(newUser);

//           // Navigate to the home screen
//           Navigator.pushReplacementNamed(context, widget.role == 'muadhin' ? '/muadhinHome' : '/userHome');
//         } else {
//           _showSnackbar('Invalid OTP');
//         }
//       } catch (e) {
//         _showSnackbar('OTP verification failed');
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // SnackBar to show errors
//   void _showSnackbar(String message) {
//     final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.red);
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   // Widget to build individual OTP input boxes
//   Widget _buildOTPInputBox(int index) {
//     return SizedBox(
//       width: 40,
//       child: TextField(
//         controller: _otpControllers[index],
//         focusNode: _focusNodes[index],
//         maxLength: 1,
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.number,
//         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         decoration: InputDecoration(
//           counterText: "", // Removes the character counter below the TextField
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//         ),
//         onChanged: (value) {
//           if (value.length == 1 && index < 5) {
//             _focusNodes[index + 1].requestFocus(); // Move to next field
//           }
//           if (value.isEmpty && index > 0) {
//             _focusNodes[index - 1].requestFocus(); // Move to previous field on backspace
//           }
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Enter OTP')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Please enter the OTP sent to your phone',
//               style: TextStyle(fontSize: 18, color: Colors.black),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),

//             // OTP input blocks
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: List.generate(6, (index) => _buildOTPInputBox(index)),
//             ),
//             const SizedBox(height: 20),

//             // Verify OTP Button
//             ElevatedButton(
//               onPressed: _isLoading ? null : _verifyOTP,
//               child: _isLoading ? CircularProgressIndicator() : Text('Verify OTP'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
