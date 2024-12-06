import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lingo_tales/services/styles.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // The Firebase AuthProvider
import 'package:lingo_tales/pages/auth/authprovider.dart'
    as custom_auth_provider;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Stream<bool> isLoggedInStream;

  CustomAppBar({required this.title, required this.isLoggedInStream});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(color: AppColors.primaryColor)),
      iconTheme: IconThemeData(color: AppColors.primaryColor),
      actions: [
        StreamBuilder<bool>(
          stream: isLoggedInStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  // Log out the user
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ],
    );
  }
}
