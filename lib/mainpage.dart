import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lingo_tales/pages/auth/authservice.dart';
import 'package:lingo_tales/pages/auth/login_page.dart';
import 'package:lingo_tales/pages/bookselection.dart';
import 'package:lingo_tales/pages/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user, // Correctly using the user stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for data
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          // If user is logged in, navigate to HomePage
          return DisplayLevelsWithBooks();
        } else {
          // If user is not logged in, navigate to LoginPage
          return LoginPage();
        }
      },
    );
  }
}
