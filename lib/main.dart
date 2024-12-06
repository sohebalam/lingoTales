import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo_tales/mainpage.dart';
import 'package:lingo_tales/pages/auth/authprovider.dart';
import 'package:lingo_tales/pages/auth/login_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lingo Tales',
        theme: ThemeData(primarySwatch: Colors.blue),
        // Listen to AuthProvider state for login status
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Navigate to MainPage if logged in, else navigate to LoginPage
            return authProvider.isLoggedIn ? MainPage() : LoginPage();
          },
        ),
        routes: {
          '/login': (context) => LoginPage(),
        },
      ),
    );
  }
}
