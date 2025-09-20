import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/core_book.dart';
import '../models/user_book_interaction.dart';

/// Migration helper for transitioning from old to new architecture
class MigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user has old format data that needs migration
  static Future<bool> needsMigration() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user has old books collection
      final oldBooksSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .limit(1)
          .get();

      return oldBooksSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking migration status: $e');
      return false;
    }
  }

  /// Migrate user data from old format to new format
  static Future<void> migrateUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('Starting migration for user: ${user.uid}');

      // Get all old books for this user
      final oldBooksSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .get();

      final batch = _firestore.batch();
      final processedBooks = <String, CoreBook>{};

      for (final doc in oldBooksSnapshot.docs) {
        try {
          final oldBook = Book.fromMap(doc.data());
          
          // Create unique book ID
          final bookId = _generateBookId(oldBook);
          
          // Create or update global book
          CoreBook globalBook;
          if (processedBooks.containsKey(bookId)) {
            globalBook = processedBooks[bookId]!;
          } else {
            globalBook = CoreBook(
              id: bookId,
              title: oldBook.title,
              author: oldBook.author,
              filePath: oldBook.filePath,
              fileName: oldBook.fileName,
              fileType: oldBook.fileType,
              totalPages: oldBook.totalPages,
              isAssetBook: oldBook.isAssetBook,
              createdAt: oldBook.dateAdded,
              updatedAt: DateTime.now(),
            );
            
            // Add to global books collection
            batch.set(
              _firestore.collection('books').doc(bookId),
              globalBook.toMap(),
            );
            
            processedBooks[bookId] = globalBook;
          }

          // Create user interaction
          final interaction = UserBookInteraction(
            bookId: bookId,
            userId: user.uid,
            currentPage: oldBook.currentPage,
            progress: oldBook.progress,
            readingTimeMinutes: oldBook.readingTimeMinutes,
            lastRead: oldBook.lastRead,
            isFavorite: oldBook.isFavorite,
            isInLibrary: true,
            dateAdded: oldBook.dateAdded,
            dateCompleted: oldBook.progress >= 1.0 ? oldBook.lastRead : null,
            updatedAt: DateTime.now(),
          );

          // Add user interaction
          batch.set(
            _firestore
                .collection('users')
                .doc(user.uid)
                .collection('user_books')
                .doc(bookId),
            interaction.toMap(),
          );

          // Mark old book for deletion
          batch.delete(doc.reference);

        } catch (e) {
          print('Error migrating book ${doc.id}: $e');
          continue;
        }
      }

      // Execute batch
      await batch.commit();
      
      print('Migration completed for user: ${user.uid}');
      print('Migrated ${oldBooksSnapshot.docs.length} books');
      
    } catch (e) {
      print('Error during migration: $e');
      throw Exception('Migration failed: $e');
    }
  }

  /// Generate consistent book ID from book data
  static String _generateBookId(Book book) {
    final baseId = '${book.title}_${book.author}_${book.fileName ?? book.title}'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    
    return baseId.length > 50 ? baseId.substring(0, 50) : baseId;
  }

  /// Validate migration results
  static Future<Map<String, dynamic>> validateMigration() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Count old format books (should be 0)
      final oldBooksSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .get();

      // Count new format interactions
      final interactionsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('user_books')
          .get();

      // Count global books user has interacted with
      final userBooks = <String>{};
      for (final doc in interactionsSnapshot.docs) {
        final interaction = UserBookInteraction.fromMap(doc.data());
        userBooks.add(interaction.bookId);
      }

      return {
        'oldBooksCount': oldBooksSnapshot.docs.length,
        'userInteractionsCount': interactionsSnapshot.docs.length,
        'uniqueBooksCount': userBooks.length,
        'migrationComplete': oldBooksSnapshot.docs.isEmpty,
      };
    } catch (e) {
      return {
        'error': 'Validation failed: $e',
        'migrationComplete': false,
      };
    }
  }

  /// Clean up any residual old data
  static Future<void> cleanupOldData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Remove any remaining old books
      final oldBooksSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .get();

      final batch = _firestore.batch();
      for (final doc in oldBooksSnapshot.docs) {
        batch.delete(doc.reference);
      }

      if (oldBooksSnapshot.docs.isNotEmpty) {
        await batch.commit();
        print('Cleaned up ${oldBooksSnapshot.docs.length} old book records');
      }
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  /// Get migration status report
  static Future<String> getMigrationReport() async {
    try {
      final validation = await validateMigration();
      
      if (validation.containsKey('error')) {
        return 'Migration Error: ${validation['error']}';
      }
      
      final report = StringBuffer();
      report.writeln('📋 MIGRATION REPORT');
      report.writeln('==================');
      report.writeln('Old books remaining: ${validation['oldBooksCount']}');
      report.writeln('User interactions: ${validation['userInteractionsCount']}');
      report.writeln('Unique books: ${validation['uniqueBooksCount']}');
      report.writeln('Status: ${validation['migrationComplete'] ? '✅ Complete' : '⚠️ Incomplete'}');
      
      return report.toString();
    } catch (e) {
      return 'Error generating report: $e';
    }
  }
}