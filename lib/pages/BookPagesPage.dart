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
      // Fetch the book details first to get the page IDs
      final bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .get();

      if (!bookSnapshot.exists) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get the page IDs from the book document
      final pageIds = List<String>.from(bookSnapshot.data()?['pages'] ?? []);

      if (pageIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch the pages from the 'pages' collection using the page IDs
      final pagesSnapshot = await FirebaseFirestore.instance
          .collection('pages')
          .where(FieldPath.documentId, whereIn: pageIds)
          .get();

      final pagesData = pagesSnapshot.docs.map((doc) {
        final data = doc.data();

        // Ensure all fields are not null and provide fallbacks if needed
        final picture = data['picture'] ?? ''; // Fallback for picture
        final text = data['text'] ?? ''; // Fallback for text
        final translations = data['translations'] ?? [];

        // Always display the original text
        String originalText = text;

        // Default to an empty string for translation
        String translatedText = '';

        // If translations exist, use the first translation's text
        if (translations.isNotEmpty) {
          final firstTranslation = translations[0];
          translatedText = firstTranslation['text'] ?? '';
        }

        return {
          'id': doc.id,
          'image': picture, // Fallback to an empty string if picture is null
          'originalText': originalText, // Always show original text
          'translatedText': translatedText, // Display translation if available
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
                      child: page['image'] != '' && page['image'] != null
                          ? Image.network(page['image'], fit: BoxFit.cover)
                          : Image.asset(
                              'assets/fallback_image.jpeg'), // Fallback image
                    ),
                    // Text and Translation on the right
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Display the original text
                            Text(
                              page['originalText'] != ''
                                  ? page['originalText']
                                  : 'No text available for this page.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                            // Display the translated text (if available)
                            SizedBox(
                                height:
                                    8.0), // Adding space between text and translation
                            Text(
                              page['translatedText'] != ''
                                  ? page['translatedText']
                                  : 'No translation available.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
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
                      child: page['image'] != '' && page['image'] != null
                          ? Image.network(page['image'],
                              fit: BoxFit.cover, width: double.infinity)
                          : Image.asset(
                              'assets/fallback_image.jpeg'), // Fallback image
                    ),
                    // Text and Translation on the bottom
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Display the original text
                            Text(
                              page['originalText'] != ''
                                  ? page['originalText']
                                  : 'No text available for this page.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                            // Display the translated text (if available)
                            SizedBox(
                                height:
                                    8.0), // Adding space between text and translation
                            Text(
                              page['translatedText'] != ''
                                  ? page['translatedText']
                                  : 'No translation available.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
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
