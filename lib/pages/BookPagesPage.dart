import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingo_tales/services/styles.dart';
import 'package:lingo_tales/services/widgets/app_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeleton_loader/skeleton_loader.dart'; // Import the skeleton loader package

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
  bool isNavigatingToLogin = false; // Flag to prevent multiple navigations
  String bookTitle = ''; // Variable to store the book title

  @override
  void initState() {
    super.initState();
    fetchPages(); // Fetch pages from Firestore
  }

  Future<void> fetchPages() async {
    try {
      final bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .get();

      if (!bookSnapshot.exists) {
        print("Book not found");
        setState(() => isLoading = false);
        return;
      }

      print("Book data: ${bookSnapshot.data()}");
      final rawPages = bookSnapshot.data()?['pages'];
      print("Raw pages field: $rawPages");

      final pageIds = rawPages is List
          ? List<String>.from(rawPages.map((e) => e.toString()))
          : [];

      if (pageIds.isEmpty) {
        print("No pages found for the book.");
        setState(() => isLoading = false);
        return;
      }

      final pagesSnapshot = await FirebaseFirestore.instance
          .collection('pages')
          .where(FieldPath.documentId, whereIn: pageIds)
          .get();

      print("Fetched pages: ${pagesSnapshot.docs}");
      final pagesData = pagesSnapshot.docs.map((doc) {
        final data = doc.data();
        print("Page data for ${doc.id}: $data");
        return {
          'id': doc.id,
          'image': data['picture'] ?? '',
          'text': data['text'] ?? '',
        };
      }).toList();

      setState(() {
        pages = pagesData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching pages: $e");
      setState(() => isLoading = false);
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Loading...',
              isLoggedInStream: FirebaseAuth.instance
                  .authStateChanges()
                  .map((user) => user != null), // Pass the stream
            ),
            body: SkeletonLoader(
              // Replace CircularProgressIndicator with SkeletonLoader
              builder: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: List.generate(
                      5,
                      (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 20.0,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                          )),
                ),
              ),
            ),
          );
        }

        if (snapshot.data == null) {
          if (!isNavigatingToLogin) {
            setState(() {
              isNavigatingToLogin =
                  true; // Set the flag to true to avoid multiple navigations
            });
            Future.microtask(() {
              Navigator.pushReplacementNamed(context, '/login');
            });
          }
          return SizedBox(); // Return an empty widget while navigating
        }

        if (isLoading) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Loading...',
              isLoggedInStream: FirebaseAuth.instance
                  .authStateChanges()
                  .map((user) => user != null), // Pass the stream
            ),
            body: SkeletonLoader(
              // Use skeleton loader during data loading
              builder: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: List.generate(
                      5,
                      (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 20.0,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                          )),
                ),
              ),
            ),
          );
        }

        if (pages.isEmpty) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'No pages available',
              isLoggedInStream: FirebaseAuth.instance
                  .authStateChanges()
                  .map((user) => user != null), // Pass the stream
            ),
            body:
                const Center(child: Text('No pages available for this book.')),
          );
        }

        final page = pages[currentPage];
        return Scaffold(
          appBar: CustomAppBar(
            title: bookTitle.isEmpty ? 'Book Pages' : bookTitle,
            isLoggedInStream: FirebaseAuth.instance
                .authStateChanges()
                .map((user) => user != null), // Pass the stream
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: page['image'] != ''
                        ? Image.network(page['image'], fit: BoxFit.cover)
                        : Image.asset('assets/fallback_image.jpeg'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      page['text'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 32),
                  color: currentPage > 0 ? AppColors.primaryColor : Colors.grey,
                  onPressed: currentPage > 0 ? _prevPage : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 32),
                  color: currentPage < pages.length - 1
                      ? AppColors.primaryColor
                      : Colors.grey,
                  onPressed: currentPage < pages.length - 1 ? _nextPage : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
