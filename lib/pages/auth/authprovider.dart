import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lingo_tales/pages/auth/authservice.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Getter to check if the user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  // Stream to listen to authentication state changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // SignIn logic
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // SignOut logic
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners(); // Notify listeners of the state change
  }
}
