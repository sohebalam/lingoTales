import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lingo_tales/services/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Stream<bool> isLoggedInStream;

  CustomAppBar({required this.title, required this.isLoggedInStream});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Set the background color to white
      elevation: 0, // Remove shadow for a clean look
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black, // Set text color to black for contrast
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        StreamBuilder<bool>(
          stream: isLoggedInStream,
          builder: (context, snapshot) {
            return IconButton(
              icon: Icon(
                snapshot.data == true ? Icons.exit_to_app : Icons.login,
                color: Colors.black, // Set icon color to black
              ),
              onPressed: () {
                // Handle login/logout functionality here
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
