import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user after OTP verification
  Future<void> registerUser(UserModel userModel) async {
    try {
      await _firestore.collection('users').doc(userModel.id).set(userModel.toMap());
    } catch (e) {
      print('Error registering user: $e');
      throw e;
    }
  }

  // Get user data by phone number
  Future<UserModel?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user by phone number: $e');
      return null;
    }
  }

  // Login with phone number and password
  Future<User?> loginWithPhoneNumberAndPassword(String phoneNumber, String password) async {
    try {
      // Get user by phone number
      UserModel? userModel = await getUserByPhoneNumber(phoneNumber);
      if (userModel != null && userModel.password == password) {
        // Use phone number as an email-like identifier for password login
        String emailForLogin = '${userModel.phoneNumber}@example.com';
        
        // If password matches, sign in the user using Firebase Email/Password method
        return _auth.signInWithEmailAndPassword(
          email: emailForLogin,
          password: userModel.password, // Password from Firestore
        ).then((userCredential) => userCredential.user);
      } else {
        throw Exception("Invalid phone number or password");
      }
    } catch (e) {
      print('Error logging in with phone number and password: $e');
      throw e;
    }
  }

  // Send OTP to the phone number
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          throw e.message ?? 'Verification failed';
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          onCodeSent(verificationId);
        },
      );
    } catch (e) {
      print('Error sending OTP: $e');
      throw e;
    }
  }

  // Verify OTP and sign in user
  Future<User?> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error verifying OTP: $e');
      throw e;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during logout: $e');
      throw e;
    }
  }
}
