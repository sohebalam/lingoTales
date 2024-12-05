import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingo_tales/services/widgets/app_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<bool> isLoggedInStream =
      FirebaseAuth.instance.authStateChanges().map((user) => user != null);

  List<Map<String, dynamic>> storyPages = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchPages(); // Fetch pages from Firestore
  }

  // Fetch pages from Firestore
  Future<void> fetchPages() async {
    try {
      // Fetch pages collection
      final snapshot =
          await FirebaseFirestore.instance.collection('pages').get();
      final pagesData = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'image': data['image'],
          'text': data['text'],
        };
      }).toList();

      setState(() {
        storyPages = pagesData;
      });
    } catch (e) {
      print("Error fetching pages: $e");
    }
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
    if (storyPages.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Storybook',
          isLoggedInStream: isLoggedInStream,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                      child: Image.network(
                        page['image'], // Use the image URL from Firestore
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
                      child: Image.network(
                        page['image'], // Use the image URL from Firestore
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
