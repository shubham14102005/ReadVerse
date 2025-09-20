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
import 'user_profile_provider.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserProfileProvider? _userProfileProvider;

  List<Book> _books = [];
  bool _isLoading = false;
  bool _booksLoaded = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Method to set the UserProfileProvider dependency
  void setUserProfileProvider(UserProfileProvider userProfileProvider) {
    _userProfileProvider = userProfileProvider;
  }

  String? _currentUserId;
  
  BookProvider() {
    // Listen to auth state changes and reload books accordingly
    _auth.authStateChanges().listen((user) {
      final newUserId = user?.uid;
      
      // Only reload if the user actually changed (not just a token refresh)
      if (_currentUserId != newUserId) {
        debugPrint('Auth state changed: ${user != null ? 'logged in' : 'logged out'}');
        _currentUserId = newUserId;
        
        // Force reload when auth state changes
        _booksLoaded = false;
        loadBooks(force: true);
      }
    });
  }

  Future<void> loadBooks({bool force = false}) async {
    // Prevent multiple simultaneous calls
    if (_isLoading) {
      debugPrint('loadBooks() already in progress, skipping...');
      return;
    }

    // Skip if books already loaded unless forced
    if (_booksLoaded && !force) {
      debugPrint('Books already loaded, skipping... (use force: true to reload)');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Clear existing books to prevent duplicates
      _books.clear();
      debugPrint('Loading books... User authenticated: ${_auth.currentUser != null}');

      // Always load asset books first
      await _loadBooksFromAssets();
      debugPrint('Asset books loaded: ${_books.length}');

      if (_auth.currentUser != null) {
        // Load from Firestore if user is authenticated
        debugPrint('Loading from Firestore...');
        await _loadBooksFromFirestore();
      } else {
        // Load from local storage
        debugPrint('Loading from local storage...');
        await _loadBooksFromLocal();
      }

      debugPrint('Total books loaded: ${_books.length}');
      _booksLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading books: $e';
      debugPrint('Error loading books: $e');
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
          isAssetBook: true, // Mark as asset book
        );
      }).toList();

      // Add asset books to the list
      _books.addAll(assetBooks);
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
          .where((book) => !book.isAssetBook) // Filter out any asset books that might be in Firestore
          .toList();
      
      // Add user books after asset books
      _books.addAll(userBooks);
      debugPrint('Loaded ${userBooks.length} user books from Firestore');
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
            .map((bookString) {
              try {
                return Book.fromMap(json.decode(bookString));
              } catch (e) {
                debugPrint('Error parsing book: $bookString, Error: $e');
                return null;
              }
            })
            .where((book) => book != null && !book!.isAssetBook) // Filter out nulls and asset books
            .cast<Book>()
            .toList();
        
        // Add local books after asset books
        _books.addAll(localBooks);
        debugPrint('Loaded ${localBooks.length} user books from local storage');
      }
    } catch (e) {
      debugPrint('Failed to load books from local storage: $e');
      // Don't throw exception for local storage, just continue without books
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
        debugPrint('Added book to list: ${book.title}, Total books: ${_books.length}');

        if (_auth.currentUser != null) {
          debugPrint('Saving book to Firestore...');
          await _saveBookToFirestore(book);
        } else {
          debugPrint('Saving book to local storage...');
          await _saveBooksToLocal();
        }

        debugPrint('Book saved successfully, notifying listeners...');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error adding book: $e';
      notifyListeners();
    }
  }

  Future<void> _saveBookToFirestore(Book book) async {
    try {
      // Don't save asset books to Firestore
      if (book.isAssetBook) {
        debugPrint('Skipping save to Firestore for asset book: ${book.title}');
        return;
      }
      
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
      // Only save user books, exclude asset books
      final userBooks = _books.where((book) => !book.isAssetBook).toList();
      final bookStrings = userBooks
          .map((book) => json.encode(book.toMap()))
          .toList();
      await prefs.setStringList('books', bookStrings);
      debugPrint('Successfully saved ${bookStrings.length} user books to local storage (excluding ${_books.length - userBooks.length} asset books)');
    } catch (e) {
      debugPrint('Failed to save books locally: $e');
      _errorMessage = 'Failed to save books locally: $e';
    }
  }

  Future<void> updateBookProgress(Book book, int currentPage) async {
    try {
      // Skip updating asset books
      if (book.isAssetBook) {
        debugPrint('Cannot update progress for asset book: ${book.title}');
        return;
      }
      
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
        final book = _books[index];
        
        // For asset books, check if user copy already exists
        if (book.isAssetBook) {
          final existingUserCopy = _findUserCopyOfAsset(book);
          
          if (existingUserCopy != null) {
            // Update existing user copy only - don't create duplicates
            final existingIndex = _books.indexWhere((b) => b.id == existingUserCopy.id);
            if (existingIndex != -1) {
              final updatedUserCopy = existingUserCopy.copyWith(
                isFavorite: !existingUserCopy.isFavorite,
              );
              
              _books[existingIndex] = updatedUserCopy;
              
              // Save the updated user copy
              if (_auth.currentUser != null) {
                await _saveBookToFirestore(updatedUserCopy);
              } else {
                await _saveBooksToLocal();
              }
              
              debugPrint('Updated existing user copy favorite status: ${book.title}');
            }
          } else {
            // Only create user copy if it doesn't exist AND the favorite status is being set to true
            if (!book.isFavorite) {  // Only create when marking as favorite
              final userCopy = book.copyWith(
                id: '${book.id}_user_copy',  // Consistent ID to prevent duplicates
                isAssetBook: false,
                isFavorite: true,
                dateAdded: DateTime.now(),
              );
              
              // Add the user copy to the list
              _books.insert(index + 1, userCopy);
              
              // Save the user copy
              if (_auth.currentUser != null) {
                await _saveBookToFirestore(userCopy);
              } else {
                await _saveBooksToLocal();
              }
              
              debugPrint('Created new user copy of asset book: ${book.title}');
            }
          }
        } else {
          // Normal user book - just update it
          final updatedBook = book.copyWith(
            isFavorite: !book.isFavorite,
          );
          
          _books[index] = updatedBook;
          
          if (_auth.currentUser != null) {
            await _saveBookToFirestore(updatedBook);
          } else {
            await _saveBooksToLocal();
          }
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
        
        // For asset books, check if user copy already exists
        if (book.isAssetBook) {
          final existingUserCopy = _findUserCopyOfAsset(book);
          
          if (existingUserCopy != null) {
            // Update existing user copy only - don't create duplicates
            final existingIndex = _books.indexWhere((b) => b.id == existingUserCopy.id);
            if (existingIndex != -1) {
              final newProgress = existingUserCopy.progress >= 1.0 ? 0.0 : 1.0;
              final updatedUserCopy = existingUserCopy.copyWith(
                progress: newProgress,
                currentPage: newProgress >= 1.0 ? existingUserCopy.totalPages : 0,
                lastRead: DateTime.now(),
              );
              
              _books[existingIndex] = updatedUserCopy;
              
              // Save the updated user copy
              if (_auth.currentUser != null) {
                await _saveBookToFirestore(updatedUserCopy);
              } else {
                await _saveBooksToLocal();
              }
              
              debugPrint('Updated existing user copy completion status: ${book.title}');
              
              // Update reading stats
              await _updateReadingStats();
            }
          } else {
            // Only create user copy if it doesn't exist AND the completion status is being changed
            if (book.progress < 1.0) {  // Only create when marking as completed
              final userCopy = book.copyWith(
                id: '${book.id}_user_copy',  // Consistent ID to prevent duplicates
                isAssetBook: false,
                progress: 1.0,
                currentPage: book.totalPages,
                lastRead: DateTime.now(),
                dateAdded: DateTime.now(),
              );
              
              // Add the user copy to the list
              _books.insert(index + 1, userCopy);
              
              // Save the user copy
              if (_auth.currentUser != null) {
                await _saveBookToFirestore(userCopy);
              } else {
                await _saveBooksToLocal();
              }
              
              debugPrint('Created new user copy of asset book for completion: ${book.title}');
              
              // Update reading stats
              await _updateReadingStats();
            }
          }
        } else {
          // Normal user book - just update it
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
          
          // Update reading stats
          await _updateReadingStats();
        }
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating completion status: $e';
      notifyListeners();
    }
  }

  // Helper method to find existing user copy of an asset book
  Book? _findUserCopyOfAsset(Book assetBook) {
    if (!assetBook.isAssetBook) return null;
    
    try {
      return _books.firstWhere(
        (book) => 
          !book.isAssetBook && 
          book.title == assetBook.title && 
          book.author == assetBook.author &&
          book.fileName == assetBook.fileName,
      );
    } catch (e) {
      // No existing user copy found
      return null;
    }
  }

  // Helper method to get completed books count
  int get completedBooksCount => _books.where((book) => !book.isAssetBook && book.progress >= 1.0).length;
  
  // Helper method to update reading stats in profile
  Future<void> _updateReadingStats() async {
    if (_userProfileProvider != null) {
      final completedCount = completedBooksCount;
      debugPrint('Updating reading stats: $completedCount completed books');
      await _userProfileProvider!.updateReadingStats(
        booksCompleted: completedCount,
      );
    }
  }

  List<Book> get favoriteBooks => _books.where((book) => book.isFavorite).toList();
  
  int get favoriteBooksCount => favoriteBooks.length;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
