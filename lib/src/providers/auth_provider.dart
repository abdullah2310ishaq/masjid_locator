import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masjid_locator/src/models/user_model.dart';
import 'package:masjid_locator/src/services/auth_service.dart';

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
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        fetchUserData();  // Fetch user data on auth state change
      } else {
        _isLoading = false;
        _userModel = null;
        notifyListeners();
      }
    });
  }

  // Fetch user data by email
  Future<void> fetchUserData() async {
    if (_user != null && _user!.email != null) {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        _userModel = await _authService.getUserByEmail(_user!.email!);
      } catch (e) {
        _error = 'Failed to fetch user data';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
  // Register with email and password
  Future<void> registerWithEmail(String email, String password, String name, String role, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      UserModel? user = await _authService.registerWithEmailAndPassword(email, password, name, role);
      if (user != null) {
        _userModel = user;
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully')),
        );
      } else {
        _error = 'Failed to register user';
      }
    } catch (e) {
      _error = 'Failed to register';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
      );
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
 Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = await _authService.loginWithEmailAndPassword(email, password);
      if (user != null) {
        // Fetch user details after successful login
        _user = user;
        await fetchUserData();
        
        // Navigate to respective homepage based on role
        if (_userModel != null) {
          if (_userModel!.role == 'muadhin') {
            Navigator.pushReplacementNamed(context, '/muadhinHome');
          } else if (_userModel!.role == 'user') {
            Navigator.pushReplacementNamed(context, '/userHome');
          }
        }
      } else {
        _error = 'Invalid email or password';
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
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
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
