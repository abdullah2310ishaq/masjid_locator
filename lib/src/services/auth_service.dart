import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Utility to hash password using SHA-256
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hashed password as a string
  }

  // Register a new user with Email and Password
  Future<UserModel?> registerWithEmailAndPassword(String email, String password, String name, String role) async {
    try {
      // Check if the email already exists in Firestore
      UserModel? existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('An account with this email already exists.');
      }

      // Register the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        String hashedPassword = hashPassword(password);

        // Create a new user document in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          phoneNumber: null, // No phone number since it's email-based
          role: role,
          password: hashedPassword,
        );
        await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

        return newUser;
      }
      return null;
    } catch (e) {
      print('Error registering with email: $e');
      throw e;
    }
  }

  // Log in the user using email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error logging in with email: $e');
      throw e;
    }
  }

  // Fetch user by email from Firestore
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
      } else {
        return null; // No user found
      }
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  // Logout the user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during logout: $e');
      throw e;
    }
  }
}
