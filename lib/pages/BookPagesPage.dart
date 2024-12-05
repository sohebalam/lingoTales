import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingo_tales/services/widgets/app_bar.dart';

class BookPagesPage extends StatefulWidget {
  final String bookId;

  BookPagesPage({required this.bookId});

  @override
  _BookPagesPageState createState() => _BookPagesPageState();
}

class _BookPagesPageState extends State<BookPagesPage> {
  final Stream<bool> isLoggedInStream =
      FirebaseAuth.instance.authStateChanges().map((user) => user != null);

  List<Map<String, dynamic>> pages = [];
  int currentPage = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPages(); // Fetch pages from Firestore
  }

  // Fetch pages from Firestore
  Future<void> fetchPages() async {
    try {
      // Fetch pages for the selected book
      final pagesSnapshot = await FirebaseFirestore.instance
          .collection('pages')
          .where('bookId', isEqualTo: widget.bookId) // Filter by bookId
          .get();

      final pagesData = pagesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'image': data['image'] ?? '', // Provide a fallback if image is null
          'text': data['text'] ?? '', // Provide a fallback if text is null
        };
      }).toList();

      setState(() {
        pages = pagesData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching pages: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _nextPage() {
    setState(() {
      if (currentPage < pages.length - 1) currentPage++;
    });
  }

  void _prevPage() {
    setState(() {
      if (currentPage > 0) currentPage--;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Book Pages',
          isLoggedInStream: isLoggedInStream,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (pages.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Book Pages',
          isLoggedInStream: isLoggedInStream,
        ),
        body: const Center(child: Text('No pages available for this book.')),
      );
    }

    final page = pages[currentPage];
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Book Pages',
        isLoggedInStream: isLoggedInStream,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isLandscape
              ? Row(
                  children: [
                    // Image on the left
                    Expanded(
                      flex: 1,
                      child: page['image'] != ''
                          ? Image.network(page['image'], fit: BoxFit.cover)
                          : Image.asset(
                              'assets/fallback_image.png'), // Fallback image
                    ),
                    // Text on the right
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          page['text'] != ''
                              ? page['text']
                              : 'No text available for this page.',
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
                      child: page['image'] != ''
                          ? Image.network(page['image'],
                              fit: BoxFit.cover, width: double.infinity)
                          : Image.asset(
                              'assets/fallback_image.png'), // Fallback image
                    ),
                    // Text on the bottom
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          page['text'] != ''
                              ? page['text']
                              : 'No text available for this page.',
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
              color: currentPage < pages.length - 1 ? Colors.blue : Colors.grey,
              onPressed: currentPage < pages.length - 1 ? _nextPage : null,
            ),
          ],
        ),
      ),
    );
  }
}
