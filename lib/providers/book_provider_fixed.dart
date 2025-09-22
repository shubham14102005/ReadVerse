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

/// HOTFIX: BookProvider with NO DUPLICATION - Quick fix for current system
/// This eliminates the book duplication issue while keeping your existing models
class BookProviderFixed with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserProfileProvider? _userProfileProvider;

  final List<Book> _books = [];
  bool _isLoading = false;
  bool _booksLoaded = false;
  String? _errorMessage;
  String? _currentUserId;
  
  // HOTFIX: Track user interactions separately to prevent duplicates
  final Map<String, Map<String, dynamic>> _userInteractions = {};

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  void setUserProfileProvider(UserProfileProvider userProfileProvider) {
    _userProfileProvider = userProfileProvider;
  }
  
  BookProviderFixed() {
    _auth.authStateChanges().listen((user) {
      final newUserId = user?.uid;
      if (_currentUserId != newUserId) {
        debugPrint('Auth state changed: ${user != null ? 'logged in' : 'logged out'}');
        _currentUserId = newUserId;
        _booksLoaded = false;
        loadBooks(force: true);
      }
    });
  }

  Future<void> loadBooks({bool force = false}) async {
    if (_isLoading) {
      debugPrint('loadBooks() already in progress, skipping...');
      return;
    }

    if (_booksLoaded && !force) {
      debugPrint('Books already loaded, skipping... (use force: true to reload)');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Clear and reload everything properly
      _books.clear();
      _userInteractions.clear();
      
      debugPrint('Loading books... User authenticated: ${_auth.currentUser != null}');

      // Load asset books first (these never change)
      await _loadBooksFromAssets();
      debugPrint('Asset books loaded: ${_books.where((b) => b.isAssetBook).length}');

      if (_auth.currentUser != null) {
        // Load user interactions (not books!)
        await _loadUserInteractions();
        // Apply interactions to asset books
        _applyUserInteractions();
        debugPrint('User interactions applied');
      } else {
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

  /// Load asset books - these are the base books, never duplicated
  Future<void> _loadBooksFromAssets() async {
    try {
      final manifestString = await rootBundle.loadString('assets/books/books_manifest.json');
      final manifestData = json.decode(manifestString) as Map<String, dynamic>;
      final List<dynamic> booksData = manifestData['books'] as List<dynamic>;

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
          isAssetBook: true,
          coverImagePath: bookData['coverImage'], // Add cover image path
        );
      }).toList();

      _books.addAll(assetBooks);
    } catch (e) {
      debugPrint('Failed to load asset books: $e');
    }
  }

  /// HOTFIX: Load user interactions only (not book copies!)
  Future<void> _loadUserInteractions() async {
    if (_currentUserId == null) return;

    try {
      // Load from new user_interactions collection instead of books
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('user_interactions')
          .get();

      for (final doc in snapshot.docs) {
        _userInteractions[doc.id] = doc.data();
      }

      debugPrint('Loaded ${_userInteractions.length} user interactions');
    } catch (e) {
      debugPrint('Error loading user interactions: $e');
      // Fallback: Load from old books collection but extract interactions only
      await _loadLegacyUserBooks();
    }
  }

  /// Fallback: Extract interactions from legacy book copies
  Future<void> _loadLegacyUserBooks() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('books')
          .where('isAssetBook', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        final bookData = doc.data();
        // Extract only the interaction data
        final bookId = _extractOriginalBookId(bookData);
        _userInteractions[bookId] = {
          'isFavorite': bookData['isFavorite'] ?? false,
          'progress': bookData['progress'] ?? 0.0,
          'currentPage': bookData['currentPage'] ?? 0,
          'readingTimeMinutes': bookData['readingTimeMinutes'] ?? 0,
          'lastRead': bookData['lastRead'],
          'dateAdded': bookData['dateAdded'] ?? DateTime.now().millisecondsSinceEpoch,
        };
      }

      debugPrint('Migrated ${_userInteractions.length} interactions from legacy books');
    } catch (e) {
      debugPrint('Error loading legacy user books: $e');
    }
  }

  /// Extract original book ID from duplicated book
  String _extractOriginalBookId(Map<String, dynamic> bookData) {
    final id = bookData['id'] as String;
    if (id.contains('_user_copy')) {
      return id.replaceAll('_user_copy', '');
    }
    return id;
  }

  /// Apply user interactions to asset books
  void _applyUserInteractions() {
    for (int i = 0; i < _books.length; i++) {
      final book = _books[i];
      if (!book.isAssetBook) continue;

      final interaction = _userInteractions[book.id];
      if (interaction != null) {
        // Apply interaction data to the original book
        _books[i] = book.copyWith(
          isFavorite: interaction['isFavorite'] ?? false,
          progress: _parseDouble(interaction['progress']),
          currentPage: _parseInt(interaction['currentPage']),
          readingTimeMinutes: _parseInt(interaction['readingTimeMinutes']),
          lastRead: interaction['lastRead'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(interaction['lastRead'])
              : null,
        );
      }
    }
  }

  /// HOTFIX: Toggle favorite WITHOUT creating duplicates!
  Future<void> toggleFavorite(String bookId) async {
    try {
      final index = _books.indexWhere((book) => book.id == bookId);
      if (index == -1) return;

      final book = _books[index];
      final newFavoriteStatus = !book.isFavorite;
      
      // Update the book in memory
      _books[index] = book.copyWith(isFavorite: newFavoriteStatus);
      
      // Save interaction separately
      await _saveUserInteraction(bookId, {
        'isFavorite': newFavoriteStatus,
        'progress': book.progress,
        'currentPage': book.currentPage,
        'readingTimeMinutes': book.readingTimeMinutes,
        'lastRead': book.lastRead?.millisecondsSinceEpoch,
        'dateAdded': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Update local tracking
      _userInteractions[bookId] = _userInteractions[bookId] ?? {};
      _userInteractions[bookId]!['isFavorite'] = newFavoriteStatus;
      
      notifyListeners();
      debugPrint('Toggled favorite for book: ${book.title} (NO DUPLICATION!)');
    } catch (e) {
      _errorMessage = 'Error updating favorite status: $e';
      notifyListeners();
    }
  }

  /// HOTFIX: Toggle completion WITHOUT creating duplicates!
  Future<void> toggleCompletion(String bookId) async {
    try {
      final index = _books.indexWhere((book) => book.id == bookId);
      if (index == -1) return;

      final book = _books[index];
      final newProgress = book.progress >= 1.0 ? 0.0 : 1.0;
      final newCurrentPage = newProgress >= 1.0 ? book.totalPages : 0;
      
      // Update the book in memory
      _books[index] = book.copyWith(
        progress: newProgress,
        currentPage: newCurrentPage,
        lastRead: DateTime.now(),
      );
      
      // Save interaction separately
      await _saveUserInteraction(bookId, {
        'isFavorite': book.isFavorite,
        'progress': newProgress,
        'currentPage': newCurrentPage,
        'readingTimeMinutes': book.readingTimeMinutes,
        'lastRead': DateTime.now().millisecondsSinceEpoch,
        'dateAdded': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Update local tracking
      _userInteractions[bookId] = _userInteractions[bookId] ?? {};
      _userInteractions[bookId]!['progress'] = newProgress;
      _userInteractions[bookId]!['currentPage'] = newCurrentPage;
      
      notifyListeners();
      await _updateReadingStats();
      debugPrint('Toggled completion for book: ${book.title} (NO DUPLICATION!)');
    } catch (e) {
      _errorMessage = 'Error updating completion status: $e';
      notifyListeners();
    }
  }

  /// Save user interaction to separate collection
  Future<void> _saveUserInteraction(String bookId, Map<String, dynamic> interaction) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('user_interactions')
          .doc(bookId)
          .set(interaction, SetOptions(merge: true));
      
      debugPrint('Saved interaction for book: $bookId');
    } catch (e) {
      debugPrint('Error saving user interaction: $e');
      throw Exception('Failed to save interaction: $e');
    }
  }

  /// Update book progress without duplication
  Future<void> updateBookProgress(Book book, int currentPage) async {
    try {
      if (book.isAssetBook) {
        final index = _books.indexWhere((b) => b.id == book.id);
        if (index != -1) {
          final updatedBook = book.copyWith(
            currentPage: currentPage,
            lastRead: DateTime.now(),
            progress: book.totalPages > 0 ? currentPage / book.totalPages : 0.0,
          );
          
          _books[index] = updatedBook;
          
          await _saveUserInteraction(book.id, {
            'isFavorite': book.isFavorite,
            'progress': updatedBook.progress,
            'currentPage': currentPage,
            'readingTimeMinutes': book.readingTimeMinutes,
            'lastRead': DateTime.now().millisecondsSinceEpoch,
            'dateAdded': DateTime.now().millisecondsSinceEpoch,
          });
          
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Error updating book progress: $e';
      notifyListeners();
    }
  }

  /// Clean up legacy duplicate books (migration helper)
  Future<void> cleanupDuplicateBooks() async {
    if (_currentUserId == null) return;

    try {
      debugPrint('Starting cleanup of duplicate books...');
      
      // Get all user books
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('books')
          .get();

      final batch = _firestore.batch();
      int cleanedCount = 0;

      for (final doc in snapshot.docs) {
        final bookData = doc.data();
        
        // If it's a user copy or duplicate, extract the interaction and delete the book
        if (bookData['id'].toString().contains('_user_copy') || 
            bookData['isAssetBook'] == false) {
          
          // Extract interaction data
          final originalBookId = _extractOriginalBookId(bookData);
          await _saveUserInteraction(originalBookId, {
            'isFavorite': bookData['isFavorite'] ?? false,
            'progress': bookData['progress'] ?? 0.0,
            'currentPage': bookData['currentPage'] ?? 0,
            'readingTimeMinutes': bookData['readingTimeMinutes'] ?? 0,
            'lastRead': bookData['lastRead'],
            'dateAdded': bookData['dateAdded'] ?? DateTime.now().millisecondsSinceEpoch,
          });
          
          // Mark for deletion
          batch.delete(doc.reference);
          cleanedCount++;
        }
      }

      if (cleanedCount > 0) {
        await batch.commit();
        debugPrint('Cleaned up $cleanedCount duplicate books');
        
        // Reload to reflect changes
        await loadBooks(force: true);
      } else {
        debugPrint('No duplicate books found to clean up');
      }
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  // Keep existing methods for compatibility...
  Future<void> _loadBooksFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localBooksJson = prefs.getStringList('local_books') ?? [];
      
      for (String bookJson in localBooksJson) {
        try {
          final bookData = json.decode(bookJson);
          final book = Book(
            id: bookData['id'],
            title: bookData['title'],
            author: bookData['author'],
            filePath: bookData['filePath'],
            fileName: bookData['fileName'],
            fileType: bookData['fileType'],
            totalPages: bookData['totalPages'] ?? 0,
            progress: (bookData['progress'] as num?)?.toDouble() ?? 0.0,
            currentPage: bookData['currentPage'] ?? 0,
            readingTimeMinutes: bookData['readingTimeMinutes'] ?? 0,
            dateAdded: DateTime.parse(bookData['dateAdded']),
            lastRead: bookData['lastRead'] != null ? DateTime.parse(bookData['lastRead']) : null,
            isFavorite: bookData['isFavorite'] ?? false,
            isAssetBook: false,
          );
          _books.add(book);
        } catch (e) {
          debugPrint('Error loading local book: $e');
        }
      }
      debugPrint('Loaded ${_books.where((b) => !b.isAssetBook).length} local books');
    } catch (e) {
      debugPrint('Error loading books from local storage: $e');
    }
  }

  Future<void> addBook() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String fileName = file.name;
        String fileType = file.extension?.toLowerCase() ?? 'unknown';

        // Create app directory if it doesn't exist
        Directory appDocDir = await getApplicationDocumentsDirectory();
        Directory booksDir = Directory('${appDocDir.path}/books');
        if (!await booksDir.exists()) {
          await booksDir.create(recursive: true);
        }

        // Copy file to app directory
        String newPath = '${booksDir.path}/$fileName';
        
        if (file.path != null) {
          File sourceFile = File(file.path!);
          await sourceFile.copy(newPath);
        } else if (file.bytes != null) {
          File newFile = File(newPath);
          await newFile.writeAsBytes(file.bytes!);
        }

        // Create book object
        Book book = Book(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: fileName.replaceAll(RegExp(r'\.[^.]+$'), ''),
          author: 'Unknown Author',
          filePath: newPath,
          fileName: fileName,
          fileType: fileType,
          totalPages: 0,
          dateAdded: DateTime.now(),
          isAssetBook: false,
        );

        _books.add(book);
        await _saveBooksToLocal();
        notifyListeners();

        debugPrint('Added new book: ${book.title}');
      }
    } catch (e) {
      _errorMessage = 'Error adding book: $e';
      debugPrint('Error adding book: $e');
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      final index = _books.indexWhere((book) => book.id == bookId);
      if (index == -1) return;

      final book = _books[index];
      
      // Delete physical file if it's not an asset book
      if (!book.isAssetBook && book.filePath.isNotEmpty) {
        try {
          final file = File(book.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting file: $e');
        }
      }

      // Remove from list
      _books.removeAt(index);
      
      // Remove user interactions if authenticated
      if (_currentUserId != null) {
        try {
          await _firestore
              .collection('users')
              .doc(_currentUserId!)
              .collection('user_interactions')
              .doc(bookId)
              .delete();
        } catch (e) {
          debugPrint('Error deleting user interaction: $e');
        }
      }
      
      // Remove from local tracking
      _userInteractions.remove(bookId);
      
      await _saveBooksToLocal();
      notifyListeners();
      
      debugPrint('Deleted book: ${book.title}');
    } catch (e) {
      _errorMessage = 'Error deleting book: $e';
      debugPrint('Error deleting book: $e');
      notifyListeners();
    }
  }

  Future<void> _saveBooksToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localBooks = _books.where((book) => !book.isAssetBook).toList();
      final booksJson = localBooks.map((book) => json.encode({
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'filePath': book.filePath,
        'fileName': book.fileName,
        'fileType': book.fileType,
        'totalPages': book.totalPages,
        'progress': book.progress,
        'currentPage': book.currentPage,
        'readingTimeMinutes': book.readingTimeMinutes,
        'dateAdded': book.dateAdded.toIso8601String(),
        'lastRead': book.lastRead?.toIso8601String(),
        'isFavorite': book.isFavorite,
        'isAssetBook': book.isAssetBook,
      })).toList();
      
      await prefs.setStringList('local_books', booksJson);
      debugPrint('Saved ${localBooks.length} local books to storage');
    } catch (e) {
      debugPrint('Error saving books to local storage: $e');
    }
  }

  int get completedBooksCount => _books.where((book) => book.progress >= 1.0).length;

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

  // Helper methods
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}