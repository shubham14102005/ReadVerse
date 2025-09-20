import 'core_book.dart';
import 'user_book_interaction.dart';

/// Combined Model for UI - Represents a book with user interaction data
/// This eliminates the need for book duplication while providing a clean interface
class UserBook {
  final CoreBook book;
  final UserBookInteraction? interaction;

  const UserBook({
    required this.book,
    this.interaction,
  });

  /// Book ID (from CoreBook)
  String get id => book.id;

  /// Book title
  String get title => book.title;

  /// Book author
  String get author => book.author;

  /// File path
  String? get filePath => book.filePath;

  /// File name
  String? get fileName => book.fileName;

  /// File type
  String get fileType => book.fileType;

  /// Total pages
  int get totalPages => book.totalPages;

  /// Cover URL
  String? get coverUrl => book.coverUrl;

  /// Description
  String? get description => book.description;

  /// Genre
  String? get genre => book.genre;

  /// Published date
  DateTime? get publishedDate => book.publishedDate;

  /// Is asset book
  bool get isAssetBook => book.isAssetBook;

  /// Book creation date
  DateTime get createdAt => book.createdAt;

  // User-specific properties (from UserBookInteraction)

  /// Current page (0 if no interaction)
  int get currentPage => interaction?.currentPage ?? 0;

  /// Reading progress (0.0 if no interaction)
  double get progress => interaction?.progress ?? 0.0;

  /// Reading time in minutes (0 if no interaction)
  int get readingTimeMinutes => interaction?.readingTimeMinutes ?? 0;

  /// Last read date (null if never read)
  DateTime? get lastRead => interaction?.lastRead;

  /// Is favorite (false if no interaction)
  bool get isFavorite => interaction?.isFavorite ?? false;

  /// Is in user's library (false if no interaction)
  bool get isInLibrary => interaction?.isInLibrary ?? false;

  /// Date added to library (null if not in library)
  DateTime? get dateAdded => interaction?.dateAdded;

  /// Date completed (null if not completed)
  DateTime? get dateCompleted => interaction?.dateCompleted;

  /// User notes (null if no notes)
  String? get notes => interaction?.notes;

  /// User rating (null if not rated)
  int? get rating => interaction?.rating;

  /// Is completed
  bool get isCompleted => interaction?.isCompleted ?? false;

  /// Completion percentage (0-100)
  int get completionPercentage => interaction?.completionPercentage ?? 0;

  /// Has user interaction
  bool get hasInteraction => interaction != null;

  /// Create UserBook from separate models
  factory UserBook.combine({
    required CoreBook book,
    UserBookInteraction? interaction,
  }) {
    return UserBook(
      book: book,
      interaction: interaction,
    );
  }

  /// Create UserBook for a book that's not in user's library
  factory UserBook.withoutInteraction(CoreBook book) {
    return UserBook(book: book);
  }

  /// Copy with new interaction data
  UserBook copyWith({
    CoreBook? book,
    UserBookInteraction? interaction,
  }) {
    return UserBook(
      book: book ?? this.book,
      interaction: interaction ?? this.interaction,
    );
  }

  /// Update interaction data
  UserBook updateInteraction(UserBookInteraction newInteraction) {
    return copyWith(interaction: newInteraction);
  }

  /// Remove interaction (remove from library)
  UserBook removeInteraction() {
    return copyWith(interaction: null);
  }

  /// Add to library
  UserBook addToLibrary(String userId) {
    final newInteraction = UserBookInteraction.addToLibrary(
      bookId: book.id,
      userId: userId,
    );
    return updateInteraction(newInteraction);
  }

  /// Toggle favorite
  UserBook toggleFavorite(String userId) {
    if (interaction != null) {
      return updateInteraction(interaction!.toggleFavorite());
    } else {
      // Create interaction if it doesn't exist
      final newInteraction = UserBookInteraction.addToLibrary(
        bookId: book.id,
        userId: userId,
      ).toggleFavorite();
      return updateInteraction(newInteraction);
    }
  }

  /// Update progress
  UserBook updateProgress({
    required String userId,
    required int currentPage,
    int? additionalReadingTime,
  }) {
    if (interaction != null) {
      return updateInteraction(
        interaction!.updateProgress(
          currentPage: currentPage,
          totalPages: totalPages,
          additionalReadingTime: additionalReadingTime,
        ),
      );
    } else {
      // Create interaction if it doesn't exist
      final newInteraction = UserBookInteraction.addToLibrary(
        bookId: book.id,
        userId: userId,
      ).updateProgress(
        currentPage: currentPage,
        totalPages: totalPages,
        additionalReadingTime: additionalReadingTime,
      );
      return updateInteraction(newInteraction);
    }
  }

  /// Mark as completed
  UserBook markAsCompleted(String userId) {
    if (interaction != null) {
      return updateInteraction(interaction!.markAsCompleted(totalPages));
    } else {
      // Create interaction if it doesn't exist
      final newInteraction = UserBookInteraction.addToLibrary(
        bookId: book.id,
        userId: userId,
      ).markAsCompleted(totalPages);
      return updateInteraction(newInteraction);
    }
  }

  /// Convert to map (for backward compatibility with existing code)
  Map<String, dynamic> toMap() {
    final bookMap = book.toMap();
    if (interaction != null) {
      // Merge interaction data into book map for backward compatibility
      bookMap.addAll({
        'currentPage': currentPage,
        'progress': progress,
        'readingTimeMinutes': readingTimeMinutes,
        'lastRead': lastRead?.millisecondsSinceEpoch,
        'isFavorite': isFavorite,
        'dateAdded': dateAdded?.millisecondsSinceEpoch,
        'dateCompleted': dateCompleted?.millisecondsSinceEpoch,
        'notes': notes,
        'rating': rating,
      });
    }
    return bookMap;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBook && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 
      'UserBook(id: $id, title: $title, hasInteraction: $hasInteraction)';
}