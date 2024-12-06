import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lingo_tales/pages/auth/authservice.dart';
import 'package:lingo_tales/pages/auth/login_page.dart';
import 'package:lingo_tales/pages/bookSelection.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user, // Listening to the auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for data
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // If user is logged in, return DisplayLevelsWithBooks
          return DisplayLevelsWithBooks();
        } else {
          // If user is not logged in, navigate to LoginPage
          // Using pushReplacement to reset the navigation stack
          return LoginPage();
        }
      },
    );
  }
}
