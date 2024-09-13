import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  Future<User?> signUpWithEmail(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        
      );
      User? user = result.user;

      if (user != null) {
        
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
        });
      }
      return user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Log in with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Log out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Get user data from Firestore
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
