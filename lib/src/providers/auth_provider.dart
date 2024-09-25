import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  UserModel? _userModel;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get role => _userModel?.role ?? '';

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        _fetchUserData(); // Fetch user data after sign-in
      } else {
        _userModel = null; // Reset user data if logged out
        notifyListeners(); // Trigger update when user logs out
      }
    });
  }

  // Fetch user data by phone number
  Future<void> _fetchUserData() async {
    if (_user != null && _user?.phoneNumber != null) {
      _isLoading = true;
      _error = null; // Clear previous errors before fetching
      notifyListeners(); // Notify UI to show a loading indicator
      try {
        _userModel = await _authService.getUserByPhoneNumber(_user!.phoneNumber!);
        if (_userModel == null) {
          _error = 'User not found';
        }
      } catch (e) {
        _error = 'Failed to fetch user data';
        print('Error: $e');
      } finally {
        _isLoading = false;
        notifyListeners(); // Update listeners with the user data or error
      }
    }
  }

  // Send OTP
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.sendOTP(phoneNumber, onCodeSent);
    } catch (e) {
      _error = 'Failed to send OTP';
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<void> verifyOTP(String verificationId, String otp, String name, String password, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      User? user = await _authService.verifyOTP(verificationId, otp);
      if (user != null) {
        UserModel newUser = UserModel(
          id: user.uid,
          name: name,
          phoneNumber: user.phoneNumber!,
          role: role,
          password: password,
        );
        await _authService.registerUser(newUser);
        _userModel = newUser;
      } else {
        _error = 'Invalid OTP';
      }
    } catch (e) {
      _error = 'Failed to verify OTP';
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.logout();
    _user = null;
    _userModel = null;
    _error = null; // Clear any existing errors
    notifyListeners();
  }

  // Clear error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
