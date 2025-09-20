import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/core_book.dart';
import '../models/user_book_interaction.dart';
import '../models/user_book.dart';
import '../services/book_service.dart';
import '../services/cache_service.dart';

/// New Library Provider - No more book duplication!
/// Separates global books from user interactions completely
class LibraryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final BookService _bookService;
  late final CacheService _cacheService;

  // Separate state for books and interactions
  Map<String, CoreBook> _books = {}; // Global books (no duplicates)
  Map<String, UserBookInteraction> _userInteractions = {}; // User-specific data
  
  bool _isLoading = false;
  bool _booksLoaded = false;
  String? _errorMessage;
  String? _currentUserId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Get all books as UserBook objects (combines CoreBook + UserBookInteraction)
  List<UserBook> get books {
    return _books.values.map((book) {
      final interaction = _userInteractions[book.id];
      return UserBook.combine(book: book, interaction: interaction);
    }).toList();
  }

  /// Get only books in user's library
  List<UserBook> get libraryBooks {
    return books.where((book) => book.isInLibrary).toList();
  }

  /// Get favorite books
  List<UserBook> get favoriteBooks {
    return books.where((book) => book.isFavorite).toList();
  }

  /// Get completed books
  List<UserBook> get completedBooks {
    return books.where((book) => book.isCompleted).toList();
  }

  /// Get reading statistics
  Map<String, int> get readingStats {
    final libraryCount = libraryBooks.length;
    final favoriteCount = favoriteBooks.length;
    final completedCount = completedBooks.length;
    final inProgressCount = libraryBooks.where((book) => 
      book.progress > 0 && book.progress < 1.0).length;

    return {
      'total': _books.length,
      'library': libraryCount,
      'favorites': favoriteCount,
      'completed': completedCount,
      'inProgress': inProgressCount,
    };
  }

  LibraryProvider() {
    _bookService = BookService();
    _cacheService = CacheService();
    
    // Listen to auth state changes
    _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    final newUserId = user?.uid;
    
    // Only reload if user actually changed (not just token refresh)
    if (_currentUserId != newUserId) {
      debugPrint('Auth state changed: ${user != null ? 'logged in' : 'logged out'}');
      _currentUserId = newUserId;
      
      // Clear current data and reload
      _userInteractions.clear();
      _booksLoaded = false;
      await loadBooks(force: true);
    }
  }

  /// Load books and user interactions
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
      _errorMessage = null;
      notifyListeners();

      // Load global books (from assets and cache)
      await _loadGlobalBooks();
      
      // Load user interactions if authenticated
      if (_currentUserId != null) {
        await _loadUserInteractions();
      }

      _booksLoaded = true;
      debugPrint('Library loaded: ${_books.length} books, ${_userInteractions.length} interactions');
    } catch (e) {
      _errorMessage = 'Error loading library: $e';
      debugPrint('Error loading library: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load global books (assets + any additional books)
  Future<void> _loadGlobalBooks() async {
    try {
      // First, try to load from cache
      final cachedBooks = await _cacheService.getCachedBooks();
      if (cachedBooks.isNotEmpty) {
        _books = {for (var book in cachedBooks) book.id: book};
        debugPrint('Loaded ${_books.length} books from cache');
      }

      // Load asset books
      final assetBooks = await _loadBooksFromAssets();
      for (final book in assetBooks) {
        _books[book.id] = book;
      }

      // Cache the updated books
      await _cacheService.cacheBooks(_books.values.toList());
      
      debugPrint('Loaded ${_books.length} global books');
    } catch (e) {
      debugPrint('Error loading global books: $e');
      // Don't throw - continue with empty books if needed
    }
  }

  /// Load asset books from manifest
  Future<List<CoreBook>> _loadBooksFromAssets() async {
    try {
      final manifestString = await rootBundle.loadString('assets/books/books_manifest.json');
      final manifestData = json.decode(manifestString) as Map<String, dynamic>;
      final List<dynamic> booksData = manifestData['books'] as List<dynamic>;

      return booksData.map((bookData) {
        final now = DateTime.now();
        return CoreBook(
          id: bookData['id'],
          title: bookData['title'],
          author: bookData['author'],
          filePath: 'assets/books/${bookData['fileName']}',
          fileName: bookData['fileName'],
          fileType: bookData['fileType'],
          totalPages: bookData['totalPages'],
          isAssetBook: true,
          createdAt: now,
          updatedAt: now,
          assetMetadata: Map<String, dynamic>.from(bookData),
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to load asset books: $e');
      return [];
    }
  }

  /// Load user interactions from Firestore
  Future<void> _loadUserInteractions() async {
    if (_currentUserId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('user_books')
          .get();

      final interactions = <String, UserBookInteraction>{};
      for (final doc in snapshot.docs) {
        final interaction = UserBookInteraction.fromMap(doc.data());
        interactions[interaction.bookId] = interaction;
      }

      _userInteractions = interactions;
      debugPrint('Loaded ${_userInteractions.length} user interactions');
    } catch (e) {
      debugPrint('Error loading user interactions: $e');
      // Try loading from local storage as fallback
      await _loadUserInteractionsFromLocal();
    }
  }

  /// Load user interactions from local storage (offline support)
  Future<void> _loadUserInteractionsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getStringList('user_interactions') ?? [];
      
      final interactions = <String, UserBookInteraction>{};
      for (final jsonStr in interactionsJson) {
        final interaction = UserBookInteraction.fromMap(json.decode(jsonStr));
        interactions[interaction.bookId] = interaction;
      }

      _userInteractions = interactions;
      debugPrint('Loaded ${_userInteractions.length} user interactions from local storage');
    } catch (e) {
      debugPrint('Error loading user interactions from local storage: $e');
    }
  }

  /// Save user interaction
  Future<void> _saveUserInteraction(UserBookInteraction interaction) async {
    try {
      if (_currentUserId != null) {
        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(_currentUserId!)
            .collection('user_books')
            .doc(interaction.bookId)
            .set(interaction.toMap());
      }

      // Always save to local storage for offline support
      await _saveUserInteractionsToLocal();
    } catch (e) {
      debugPrint('Error saving user interaction: $e');
      throw Exception('Failed to save interaction: $e');
    }
  }

  /// Save user interactions to local storage
  Future<void> _saveUserInteractionsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = _userInteractions.values
          .map((interaction) => json.encode(interaction.toMap()))
          .toList();
      
      await prefs.setStringList('user_interactions', interactionsJson);
    } catch (e) {
      debugPrint('Error saving user interactions to local storage: $e');
    }
  }

  /// Remove user interaction
  Future<void> _removeUserInteraction(String bookId) async {
    try {
      if (_currentUserId != null) {
        // Remove from Firestore
        await _firestore
            .collection('users')
            .doc(_currentUserId!)
            .collection('user_books')
            .doc(bookId)
            .delete();
      }

      // Remove from memory
      _userInteractions.remove(bookId);
      
      // Update local storage
      await _saveUserInteractionsToLocal();
    } catch (e) {
      debugPrint('Error removing user interaction: $e');
      throw Exception('Failed to remove interaction: $e');
    }
  }

  // ===== USER ACTIONS =====

  /// Toggle favorite status
  Future<void> toggleFavorite(String bookId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to perform this action');
    }

    try {
      final currentInteraction = _userInteractions[bookId];
      UserBookInteraction newInteraction;

      if (currentInteraction != null) {
        // Update existing interaction
        newInteraction = currentInteraction.toggleFavorite();
      } else {
        // Create new interaction
        newInteraction = UserBookInteraction.addToLibrary(
          bookId: bookId,
          userId: _currentUserId!,
        ).toggleFavorite();
      }

      // Update in memory
      _userInteractions[bookId] = newInteraction;
      
      // Save to storage
      await _saveUserInteraction(newInteraction);
      
      notifyListeners();
      debugPrint('Toggled favorite for book: $bookId');
    } catch (e) {
      _errorMessage = 'Error updating favorite status: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Add book to library
  Future<void> addToLibrary(String bookId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to perform this action');
    }

    try {
      UserBookInteraction interaction;
      
      if (_userInteractions.containsKey(bookId)) {
        // Update existing interaction
        interaction = _userInteractions[bookId]!.copyWith(
          isInLibrary: true,
          updatedAt: DateTime.now(),
        );
      } else {
        // Create new interaction
        interaction = UserBookInteraction.addToLibrary(
          bookId: bookId,
          userId: _currentUserId!,
        );
      }

      // Update in memory
      _userInteractions[bookId] = interaction;
      
      // Save to storage
      await _saveUserInteraction(interaction);
      
      notifyListeners();
      debugPrint('Added book to library: $bookId');
    } catch (e) {
      _errorMessage = 'Error adding book to library: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove book from library
  Future<void> removeFromLibrary(String bookId) async {
    if (_currentUserId == null) return;

    try {
      await _removeUserInteraction(bookId);
      notifyListeners();
      debugPrint('Removed book from library: $bookId');
    } catch (e) {
      _errorMessage = 'Error removing book from library: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update reading progress
  Future<void> updateProgress({
    required String bookId,
    required int currentPage,
    int? additionalReadingTime,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to perform this action');
    }

    try {
      final book = _books[bookId];
      if (book == null) {
        throw Exception('Book not found: $bookId');
      }

      UserBookInteraction interaction;
      
      if (_userInteractions.containsKey(bookId)) {
        // Update existing interaction
        interaction = _userInteractions[bookId]!.updateProgress(
          currentPage: currentPage,
          totalPages: book.totalPages,
          additionalReadingTime: additionalReadingTime,
        );
      } else {
        // Create new interaction
        interaction = UserBookInteraction.addToLibrary(
          bookId: bookId,
          userId: _currentUserId!,
        ).updateProgress(
          currentPage: currentPage,
          totalPages: book.totalPages,
          additionalReadingTime: additionalReadingTime,
        );
      }

      // Update in memory
      _userInteractions[bookId] = interaction;
      
      // Save to storage
      await _saveUserInteraction(interaction);
      
      notifyListeners();
      debugPrint('Updated progress for book: $bookId (${interaction.completionPercentage}%)');
    } catch (e) {
      _errorMessage = 'Error updating progress: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Mark book as completed
  Future<void> markAsCompleted(String bookId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to perform this action');
    }

    try {
      final book = _books[bookId];
      if (book == null) {
        throw Exception('Book not found: $bookId');
      }

      UserBookInteraction interaction;
      
      if (_userInteractions.containsKey(bookId)) {
        // Update existing interaction
        interaction = _userInteractions[bookId]!.markAsCompleted(book.totalPages);
      } else {
        // Create new interaction
        interaction = UserBookInteraction.addToLibrary(
          bookId: bookId,
          userId: _currentUserId!,
        ).markAsCompleted(book.totalPages);
      }

      // Update in memory
      _userInteractions[bookId] = interaction;
      
      // Save to storage
      await _saveUserInteraction(interaction);
      
      notifyListeners();
      debugPrint('Marked book as completed: $bookId');
    } catch (e) {
      _errorMessage = 'Error marking book as completed: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Rate book
  Future<void> rateBook(String bookId, int rating) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to perform this action');
    }

    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    try {
      UserBookInteraction interaction;
      
      if (_userInteractions.containsKey(bookId)) {
        // Update existing interaction
        interaction = _userInteractions[bookId]!.copyWith(
          rating: rating,
          updatedAt: DateTime.now(),
        );
      } else {
        // Create new interaction
        interaction = UserBookInteraction.addToLibrary(
          bookId: bookId,
          userId: _currentUserId!,
        ).copyWith(rating: rating);
      }

      // Update in memory
      _userInteractions[bookId] = interaction;
      
      // Save to storage
      await _saveUserInteraction(interaction);
      
      notifyListeners();
      debugPrint('Rated book: $bookId ($rating stars)');
    } catch (e) {
      _errorMessage = 'Error rating book: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get a specific book by ID
  UserBook? getBook(String bookId) {
    final book = _books[bookId];
    if (book == null) return null;
    
    final interaction = _userInteractions[bookId];
    return UserBook.combine(book: book, interaction: interaction);
  }

  /// Search books
  List<UserBook> searchBooks(String query) {
    if (query.isEmpty) return books;
    
    final lowercaseQuery = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(lowercaseQuery) ||
             book.author.toLowerCase().contains(lowercaseQuery) ||
             (book.genre?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Filter books by genre
  List<UserBook> filterByGenre(String genre) {
    return books.where((book) => book.genre == genre).toList();
  }

  /// Get unique genres
  Set<String> get availableGenres {
    return books
        .where((book) => book.genre != null)
        .map((book) => book.genre!)
        .toSet();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh library (force reload)
  Future<void> refresh() async {
    await loadBooks(force: true);
  }

  /// Sync offline changes (when coming back online)
  Future<void> syncOfflineChanges() async {
    if (_currentUserId == null) return;

    try {
      // This would sync any offline changes with the server
      // Implementation depends on your offline strategy
      debugPrint('Syncing offline changes...');
      
      // For now, just reload everything
      await loadBooks(force: true);
    } catch (e) {
      debugPrint('Error syncing offline changes: $e');
    }
  }
}