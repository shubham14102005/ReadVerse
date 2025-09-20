import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/core_book.dart';

/// Cache Service for offline support and performance optimization
class CacheService {
  static const String _booksKey = 'cached_books';
  static const String _booksCacheTimestamp = 'books_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  /// Get cached books
  Future<List<CoreBook>> getCachedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if cache is still valid
      final cacheTimestamp = prefs.getInt(_booksCacheTimestamp);
      if (cacheTimestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
        final now = DateTime.now();
        
        if (now.difference(cacheTime) > _cacheValidDuration) {
          // Cache expired, clear it
          await clearBooksCache();
          return [];
        }
      }

      final cachedBooksJson = prefs.getStringList(_booksKey) ?? [];
      return cachedBooksJson.map((jsonStr) {
        return CoreBook.fromMap(json.decode(jsonStr));
      }).toList();
    } catch (e) {
      print('Error loading cached books: $e');
      return [];
    }
  }

  /// Cache books
  Future<void> cacheBooks(List<CoreBook> books) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final booksJson = books.map((book) {
        return json.encode(book.toMap());
      }).toList();
      
      await prefs.setStringList(_booksKey, booksJson);
      await prefs.setInt(_booksCacheTimestamp, DateTime.now().millisecondsSinceEpoch);
      
      print('Cached ${books.length} books');
    } catch (e) {
      print('Error caching books: $e');
    }
  }

  /// Clear books cache
  Future<void> clearBooksCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_booksKey);
      await prefs.remove(_booksCacheTimestamp);
      
      print('Books cache cleared');
    } catch (e) {
      print('Error clearing books cache: $e');
    }
  }

  /// Check if cache is valid
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimestamp = prefs.getInt(_booksCacheTimestamp);
      
      if (cacheTimestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheValidDuration;
    } catch (e) {
      return false;
    }
  }

  /// Get cache info
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimestamp = prefs.getInt(_booksCacheTimestamp);
      final cachedBooksJson = prefs.getStringList(_booksKey) ?? [];
      
      return {
        'hasCachedBooks': cachedBooksJson.isNotEmpty,
        'cachedBooksCount': cachedBooksJson.length,
        'cacheTimestamp': cacheTimestamp,
        'isCacheValid': await isCacheValid(),
      };
    } catch (e) {
      return {
        'hasCachedBooks': false,
        'cachedBooksCount': 0,
        'cacheTimestamp': null,
        'isCacheValid': false,
      };
    }
  }
}