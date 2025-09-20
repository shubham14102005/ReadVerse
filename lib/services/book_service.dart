import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/core_book.dart';

/// Book Service for handling book-related operations
class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new book to the global books collection (admin/content manager only)
  Future<CoreBook> addBook({
    required String title,
    required String author,
    String? description,
    String? genre,
    String? coverUrl,
    required String fileType,
    required int totalPages,
    String? filePath,
    String? fileName,
  }) async {
    try {
      final now = DateTime.now();
      final bookId = _firestore.collection('books').doc().id;

      final book = CoreBook(
        id: bookId,
        title: title,
        author: author,
        description: description,
        genre: genre,
        coverUrl: coverUrl,
        fileType: fileType,
        totalPages: totalPages,
        filePath: filePath,
        fileName: fileName,
        isAssetBook: false,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore books collection
      await _firestore
          .collection('books')
          .doc(bookId)
          .set(book.toMap());

      return book;
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  /// Get all books from the global collection
  Future<List<CoreBook>> getAllBooks() async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CoreBook.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  /// Get a specific book by ID
  Future<CoreBook?> getBook(String bookId) async {
    try {
      final doc = await _firestore
          .collection('books')
          .doc(bookId)
          .get();

      if (doc.exists) {
        return CoreBook.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch book: $e');
    }
  }

  /// Update a book (admin/content manager only)
  Future<void> updateBook(String bookId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore
          .collection('books')
          .doc(bookId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  /// Delete a book (admin only)
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore
          .collection('books')
          .doc(bookId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  /// Search books
  Future<List<CoreBook>> searchBooks(String query) async {
    try {
      // Note: Firestore doesn't support full-text search out of the box
      // For production, consider using Algolia, Elasticsearch, or similar
      final snapshot = await _firestore
          .collection('books')
          .get();

      final allBooks = snapshot.docs
          .map((doc) => CoreBook.fromMap(doc.data()))
          .toList();

      // Client-side filtering (for demo purposes)
      final lowercaseQuery = query.toLowerCase();
      return allBooks.where((book) {
        return book.title.toLowerCase().contains(lowercaseQuery) ||
               book.author.toLowerCase().contains(lowercaseQuery) ||
               (book.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
               (book.genre?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search books: $e');
    }
  }

  /// Get books by genre
  Future<List<CoreBook>> getBooksByGenre(String genre) async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .where('genre', isEqualTo: genre)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CoreBook.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch books by genre: $e');
    }
  }

  /// Add book from file picker (user uploads)
  Future<CoreBook?> addBookFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final fileName = file.name;
      final fileType = fileName.split('.').last.toLowerCase();

      if (!['pdf', 'epub', 'txt'].contains(fileType)) {
        throw Exception('Unsupported file format. Please select PDF, EPUB, or TXT files.');
      }

      // Copy file to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${appDir.path}/user_books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      final filePath = '${booksDir.path}/$fileName';
      final newFile = File(filePath);
      await newFile.writeAsBytes(file.bytes!);

      // Create book object (this would be added to global collection by admin)
      final now = DateTime.now();
      final title = fileName.replaceAll('.$fileType', '');
      
      final book = CoreBook(
        id: now.millisecondsSinceEpoch.toString(),
        title: title,
        author: 'Unknown Author',
        filePath: filePath,
        fileName: fileName,
        fileType: fileType,
        totalPages: 0, // Would be calculated when first opened
        isAssetBook: false,
        createdAt: now,
        updatedAt: now,
      );

      return book;
    } catch (e) {
      throw Exception('Error adding book from file: $e');
    }
  }

  /// Get available genres
  Future<List<String>> getAvailableGenres() async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .get();

      final genres = <String>{};
      for (final doc in snapshot.docs) {
        final book = CoreBook.fromMap(doc.data());
        if (book.genre != null && book.genre!.isNotEmpty) {
          genres.add(book.genre!);
        }
      }

      return genres.toList()..sort();
    } catch (e) {
      throw Exception('Failed to fetch genres: $e');
    }
  }

  /// Get book statistics
  Future<Map<String, int>> getBookStats() async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .get();

      final books = snapshot.docs
          .map((doc) => CoreBook.fromMap(doc.data()))
          .toList();

      final genres = <String>{};
      var assetBooksCount = 0;
      var userBooksCount = 0;

      for (final book in books) {
        if (book.genre != null) {
          genres.add(book.genre!);
        }
        
        if (book.isAssetBook) {
          assetBooksCount++;
        } else {
          userBooksCount++;
        }
      }

      return {
        'total': books.length,
        'assetBooks': assetBooksCount,
        'userBooks': userBooksCount,
        'genres': genres.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch book statistics: $e');
    }
  }
}