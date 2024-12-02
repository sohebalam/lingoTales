import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lingo_tales/services/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Dummy JSON data for storybook pages
const String storyPagesJson = '''
[
  {"image": "assets/page1.jpeg", "text": "Once upon a time in a magical forest..."},
  {"image": "assets/page2.jpeg", "text": "There lived a brave little fox named Felix."},
  {"image": "assets/page3.jpeg", "text": "Felix loved to explore new places and make new friends."},
  {"image": "assets/page4.jpeg", "text": "One day, Felix discovered a hidden treasure..."}
]
''';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<bool> isLoggedInStream =
      FirebaseAuth.instance.authStateChanges().map((user) => user != null);

  late List<dynamic> storyPages;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    storyPages = jsonDecode(storyPagesJson);
  }

  void _nextPage() {
    setState(() {
      if (currentPage < storyPages.length - 1) currentPage++;
    });
  }

  void _prevPage() {
    setState(() {
      if (currentPage > 0) currentPage--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = storyPages[currentPage];
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Storybook',
        isLoggedInStream: isLoggedInStream,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLandscape
              ? Row(
                  children: [
                    // Image on the left
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        page['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Text on the right
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          page['text'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Image on top
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        page['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    // Text on the bottom
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          page['text'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      // Navigation arrows
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 32),
              color: currentPage > 0 ? Colors.blue : Colors.grey,
              onPressed: currentPage > 0 ? _prevPage : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, size: 32),
              color: currentPage < storyPages.length - 1
                  ? Colors.blue
                  : Colors.grey,
              onPressed: currentPage < storyPages.length - 1 ? _nextPage : null,
            ),
          ],
        ),
      ),
    );
  }
}
