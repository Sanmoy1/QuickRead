import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String _error = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case "email-already-in-use":
        return "Email already used. Go to login page.";
      case "invalid-email":
        return "Invalid email address.";
      case "weak-password":
        return "Password is too weak.";
      case "user-not-found":
        return "No user found with this email.";
      case "wrong-password":
        return "Wrong password provided.";
      case "user-disabled":
        return "User account has been disabled.";
      case "too-many-requests":
        return "Too many requests. Try again later.";
      case "operation-not-allowed":
        return "Email & Password accounts are not enabled.";
      default:
        return "An undefined error occurred.";
    }
  }
}
