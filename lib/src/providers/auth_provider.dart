import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  UserModel? _userModel;
  final AuthService _authService = AuthService();

  User? get user => _user;
  UserModel? get userModel => _userModel;
  String get role => _userModel?.role ?? ''; // Fetch the role from UserModel

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        _fetchUserData();  // Fetch user data from Firestore
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      _userModel = await _authService.getUserData(_user!.uid);
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.logout();
    _user = null;
    _userModel = null;
    notifyListeners();
  }
}
