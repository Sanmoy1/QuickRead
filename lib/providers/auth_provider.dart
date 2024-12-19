import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _error = '';
  bool _isLoading = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  String get error => _error;
  bool get isLoading => _isLoading;
  User? get user => _user;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _getReadableError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _getReadableError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _auth.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = _getReadableError(e);
      notifyListeners();
      rethrow;
    }
  }

  String _getReadableError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password provided';
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak';
        case 'operation-not-allowed':
          return 'Operation not allowed';
        case 'user-disabled':
          return 'User has been disabled';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An error occurred: $error';
  }
}
