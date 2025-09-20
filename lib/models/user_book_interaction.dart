/// User Book Interaction Model - Stores user-specific book data (no duplication)
class UserBookInteraction {
  final String bookId; // Reference to CoreBook
  final String userId;
  final int currentPage;
  final double progress; // 0.0 to 1.0
  final int readingTimeMinutes;
  final DateTime? lastRead;
  final bool isFavorite;
  final bool isInLibrary;
  final DateTime dateAdded;
  final DateTime? dateCompleted;
  final String? notes;
  final int? rating; // 1-5 stars
  final DateTime updatedAt;

  const UserBookInteraction({
    required this.bookId,
    required this.userId,
    this.currentPage = 0,
    this.progress = 0.0,
    this.readingTimeMinutes = 0,
    this.lastRead,
    this.isFavorite = false,
    this.isInLibrary = false,
    required this.dateAdded,
    this.dateCompleted,
    this.notes,
    this.rating,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'currentPage': currentPage,
      'progress': progress,
      'readingTimeMinutes': readingTimeMinutes,
      'lastRead': lastRead?.toIso8601String(),
      'isFavorite': isFavorite,
      'isInLibrary': isInLibrary,
      'dateAdded': dateAdded.toIso8601String(),
      'dateCompleted': dateCompleted?.toIso8601String(),
      'notes': notes,
      'rating': rating,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserBookInteraction.fromMap(Map<String, dynamic> map) {
    return UserBookInteraction(
      bookId: map['bookId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      currentPage: _parseInt(map['currentPage']),
      progress: _parseDouble(map['progress']),
      readingTimeMinutes: _parseInt(map['readingTimeMinutes']),
      lastRead: _parseDateTime(map['lastRead']),
      isFavorite: _parseBool(map['isFavorite']),
      isInLibrary: _parseBool(map['isInLibrary']),
      dateAdded: _parseDateTime(map['dateAdded']) ?? DateTime.now(),
      dateCompleted: _parseDateTime(map['dateCompleted']),
      notes: map['notes']?.toString(),
      rating: map['rating'] != null ? _parseInt(map['rating']) : null,
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  UserBookInteraction copyWith({
    String? bookId,
    String? userId,
    int? currentPage,
    double? progress,
    int? readingTimeMinutes,
    DateTime? lastRead,
    bool? isFavorite,
    bool? isInLibrary,
    DateTime? dateAdded,
    DateTime? dateCompleted,
    String? notes,
    int? rating,
    DateTime? updatedAt,
  }) {
    return UserBookInteraction(
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      currentPage: currentPage ?? this.currentPage,
      progress: progress ?? this.progress,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      lastRead: lastRead ?? this.lastRead,
      isFavorite: isFavorite ?? this.isFavorite,
      isInLibrary: isInLibrary ?? this.isInLibrary,
      dateAdded: dateAdded ?? this.dateAdded,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if the book is completed
  bool get isCompleted => progress >= 1.0;

  /// Get completion percentage as integer (0-100)
  int get completionPercentage => (progress * 100).round();

  /// Create a new interaction when user adds book to library
  factory UserBookInteraction.addToLibrary({
    required String bookId,
    required String userId,
  }) {
    final now = DateTime.now();
    return UserBookInteraction(
      bookId: bookId,
      userId: userId,
      isInLibrary: true,
      dateAdded: now,
      updatedAt: now,
    );
  }

  /// Update progress
  UserBookInteraction updateProgress({
    required int currentPage,
    required int totalPages,
    int? additionalReadingTime,
  }) {
    final newProgress = totalPages > 0 ? currentPage / totalPages : 0.0;
    final now = DateTime.now();
    
    return copyWith(
      currentPage: currentPage,
      progress: newProgress.clamp(0.0, 1.0),
      readingTimeMinutes: additionalReadingTime != null 
          ? readingTimeMinutes + additionalReadingTime 
          : readingTimeMinutes,
      lastRead: now,
      dateCompleted: newProgress >= 1.0 && dateCompleted == null ? now : dateCompleted,
      updatedAt: now,
    );
  }

  /// Toggle favorite status
  UserBookInteraction toggleFavorite() {
    return copyWith(
      isFavorite: !isFavorite,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as completed
  UserBookInteraction markAsCompleted(int totalPages) {
    final now = DateTime.now();
    return copyWith(
      currentPage: totalPages,
      progress: 1.0,
      lastRead: now,
      dateCompleted: now,
      updatedAt: now,
    );
  }

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

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBookInteraction && 
      runtimeType == other.runtimeType &&
      bookId == other.bookId &&
      userId == other.userId;

  @override
  int get hashCode => Object.hash(bookId, userId);

  @override
  String toString() => 
      'UserBookInteraction(bookId: $bookId, userId: $userId, progress: $progress)';
}