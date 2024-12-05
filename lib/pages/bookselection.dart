import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingo_tales/pages/bookPagesPage.dart';

class DisplayLevelsWithBooks extends StatefulWidget {
  @override
  _DisplayLevelsWithBooksState createState() => _DisplayLevelsWithBooksState();
}

class _DisplayLevelsWithBooksState extends State<DisplayLevelsWithBooks> {
  List<Map<String, dynamic>> levels = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchLevels();
  }

  Future<void> fetchLevels() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch levels from Firestore
      final levelsSnapshot =
          await FirebaseFirestore.instance.collection('levels').get();

      final levelsData = await Future.wait(
        levelsSnapshot.docs.map((levelDoc) async {
          final levelData = levelDoc.data();
          final bookIds = levelData['books'] ?? [];

          // Fetch books associated with the level
          final books = await Future.wait(
            bookIds.map<Future<Map<String, dynamic>?>>((bookId) async {
              final bookSnap = await FirebaseFirestore.instance
                  .collection('books')
                  .doc(bookId)
                  .get();
              return bookSnap.exists
                  ? {'id': bookSnap.id, ...bookSnap.data()!}
                  : null;
            }).toList(),
          );

          return {
            'id': levelDoc.id,
            'name': levelData['name'],
            'books': books.where((book) => book != null).toList(),
          };
        }),
      );

      setState(() {
        levels = levelsData;
      });
    } catch (e) {
      print('Error fetching levels: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToBookPages(String bookId) {
    // Navigate to the book pages screen, passing the bookId as a parameter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookPagesPage(bookId: bookId), // Make sure you define this screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels with Books'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ExpansionTile(
                    title: Text(
                      level['name'] ?? 'Unknown Level',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: level['books'].isNotEmpty
                        ? level['books'].map<Widget>((book) {
                            return ListTile(
                              title: Text(book['name'] ?? 'Unknown Book'),
                              onTap: () => _navigateToBookPages(
                                  book['id']), // Handle tap to navigate
                            );
                          }).toList()
                        : [
                            const ListTile(
                              title: Text('No books assigned to this level'),
                            ),
                          ],
                  ),
                );
              },
            ),
    );
  }
}
