import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:masjid_locator/src/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _role;
  final AuthService _authService = AuthService();

  User? get user => _user;
  String? get role => _role;

  AuthProvider() {
    _authService.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        _fetchUserRole(_user!.uid);
      }
      notifyListeners();
    });
  }

Future<void> _fetchUserRole(String uid) async {
  final doc = await _authService.getUserData(uid);
  if (doc != null) {
    _role = doc['role'];
    print('Fetched role: $_role');  // Debugging role
  } else {
    print('Error fetching role');
  }
  notifyListeners();
}

  Future<void> signIn(String email, String password) async {
    User? user = await _authService.loginWithEmail(email, password);
    if (user != null) {
      _user = user;
      await _fetchUserRole(_user!.uid);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.logout();
    _user = null;
    _role = null;
    notifyListeners();
  }
}
