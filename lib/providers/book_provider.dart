import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookProvider() {
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Always load asset books first
      await _loadBooksFromAssets();

      if (_auth.currentUser != null) {
        // Load from Firestore if user is authenticated
        await _loadBooksFromFirestore();
      } else {
        // Load from local storage
        await _loadBooksFromLocal();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading books: $e';
      notifyListeners();
    }
  }

  Future<void> _loadBooksFromAssets() async {
    try {
      // Load the books manifest
      final manifestString = await rootBundle.loadString('assets/books/books_manifest.json');
      final manifestData = json.decode(manifestString) as Map<String, dynamic>;
      final List<dynamic> booksData = manifestData['books'] as List<dynamic>;

      // Create Book objects from asset books
      final assetBooks = booksData.map((bookData) {
        return Book(
          id: bookData['id'],
          title: bookData['title'],
          author: bookData['author'],
          filePath: 'assets/books/${bookData['fileName']}',
          fileName: bookData['fileName'],
          fileType: bookData['fileType'],
          totalPages: bookData['totalPages'],
          dateAdded: DateTime.now(),
        );
      }).toList();

      // Add asset books to the beginning of the list
      _books.insertAll(0, assetBooks);
    } catch (e) {
      debugPrint('Failed to load asset books: $e');
      // Don't throw error for asset books, continue loading other books
    }
  }

  Future<void> _loadBooksFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('books')
          .orderBy('dateAdded', descending: true)
          .get();

      final userBooks = snapshot.docs
          .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Add user books after asset books
      _books.addAll(userBooks);
    } catch (e) {
      throw Exception('Failed to load books from cloud: $e');
    }
  }

  Future<void> _loadBooksFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? bookStrings = prefs.getStringList('books');

      if (bookStrings != null) {
        final localBooks = bookStrings
            .map((bookString) => Book.fromMap(
                Map<String, dynamic>.from(Uri.splitQueryString(bookString))))
            .toList();
        
        // Add local books after asset books
        _books.addAll(localBooks);
      }
    } catch (e) {
      throw Exception('Failed to load books from local storage: $e');
    }
  }

  Future<void> addBook() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final fileType = fileName.split('.').last.toLowerCase();

        if (fileType != 'pdf' && fileType != 'epub') {
          _errorMessage =
              'Unsupported file format. Please select PDF or EPUB files.';
          notifyListeners();
          return;
        }

        // Copy file to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final booksDir = Directory('${appDir.path}/books');
        if (!await booksDir.exists()) {
          await booksDir.create(recursive: true);
        }

        final filePath = '${booksDir.path}/$fileName';
        final newFile = File(filePath);
        await newFile.writeAsBytes(file.bytes!);

        // Create book object
        final book = Book(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: fileName.replaceAll('.$fileType', ''),
          author: 'Unknown Author',
          filePath: filePath,
          fileName: fileName,
          fileType: fileType,
          totalPages: 0, // Will be updated when book is opened
          dateAdded: DateTime.now(),
        );

        _books.insert(0, book);

        if (_auth.currentUser != null) {
          await _saveBookToFirestore(book);
        } else {
          await _saveBooksToLocal();
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error adding book: $e';
      notifyListeners();
    }
  }

  Future<void> _saveBookToFirestore(Book book) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('books')
          .doc(book.id)
          .set(book.toMap());
    } catch (e) {
      throw Exception('Failed to save book to cloud: $e');
    }
  }

  Future<void> _saveBooksToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookStrings = _books
          .map((book) => Uri(
              queryParameters: book
                  .toMap()
                  .map((key, value) => MapEntry(key, value.toString()))).query)
          .toList();
      await prefs.setStringList('books', bookStrings);
    } catch (e) {
      throw Exception('Failed to save books locally: $e');
    }
  }

  Future<void> updateBookProgress(Book book, int currentPage) async {
    try {
      final updatedBook = book.copyWith(
        currentPage: currentPage,
        lastRead: DateTime.now(),
        progress: book.totalPages > 0 ? currentPage / book.totalPages : 0.0,
      );

      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = updatedBook;

        if (_auth.currentUser != null) {
          await _saveBookToFirestore(updatedBook);
        } else {
          await _saveBooksToLocal();
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating book progress: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      final book = _books.firstWhere((b) => b.id == bookId);

      // Delete file from storage
      final file = File(book.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from list
      _books.removeWhere((b) => b.id == bookId);

      if (_auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('books')
            .doc(bookId)
            .delete();
      } else {
        await _saveBooksToLocal();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting book: $e';
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String bookId) async {
    try {
      final index = _books.indexWhere((book) => book.id == bookId);
      if (index != -1) {
        final updatedBook = _books[index].copyWith(
          isFavorite: !_books[index].isFavorite,
        );
        
        _books[index] = updatedBook;
        
        if (_auth.currentUser != null) {
          await _saveBookToFirestore(updatedBook);
        } else {
          await _saveBooksToLocal();
        }
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating favorite status: $e';
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(String bookId) async {
    try {
      final index = _books.indexWhere((book) => book.id == bookId);
      if (index != -1) {
        final book = _books[index];
        final newProgress = book.progress >= 1.0 ? 0.0 : 1.0;
        final updatedBook = book.copyWith(
          progress: newProgress,
          currentPage: newProgress >= 1.0 ? book.totalPages : 0,
          lastRead: DateTime.now(),
        );
        
        _books[index] = updatedBook;
        
        if (_auth.currentUser != null) {
          await _saveBookToFirestore(updatedBook);
        } else {
          await _saveBooksToLocal();
        }
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating completion status: $e';
      notifyListeners();
    }
  }

  List<Book> get favoriteBooks => _books.where((book) => book.isFavorite).toList();
  
  int get favoriteBooksCount => favoriteBooks.length;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
