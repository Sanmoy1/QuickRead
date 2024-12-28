import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    signInOption: SignInOption.standard,
  );
  User? _user;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isSigningUp = false;
  String _error = '';

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isSigningUp => _isSigningUp;//this is a public getter 
  String get error => _error;
  User? get user => _user;

  Future<bool> signIn(String email, String password) async {
    try {
      _isEmailLoading = true;
      _error = '';
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _isEmailLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isEmailLoading = false;
      _error = _getReadableError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _isSigningUp = true;
      _error = '';
      notifyListeners();

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _isSigningUp = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSigningUp = false;
      _error = _getReadableError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isGoogleLoading = true;
      _error = '';
      notifyListeners();

      // Sign out from any existing Google session
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in flow
      if (googleUser == null) {
        _isGoogleLoading = false;
        _error = 'Google sign in was cancelled';
        notifyListeners();
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      _user = result.user;
      _isGoogleLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isGoogleLoading = false;
      _error = _getReadableError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isEmailLoading = false;
      _isGoogleLoading = false;
      _isSigningUp = false;
      _error = '';
      notifyListeners();

      // Sign out from Google
      await _googleSignIn.signOut();
      // Sign out from Firebase
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
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
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials';
        case 'invalid-credential':
          return 'The credential is malformed or has expired';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return error.toString();
  }
}
