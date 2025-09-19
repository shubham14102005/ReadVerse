class UserProfile {
  final String userId;
  final String displayName;
  final String email;
  final String profileImageUrl;
  final int readingGoal;
  final int booksCompletedThisYear;
  final int totalReadingTimeMinutes;
  final DateTime joinDate;
  final List<String> achievements;
  final Map<String, dynamic> settings;

  UserProfile({
    required this.userId,
    required this.displayName,
    required this.email,
    this.profileImageUrl = '',
    this.readingGoal = 12,
    this.booksCompletedThisYear = 0,
    this.totalReadingTimeMinutes = 0,
    required this.joinDate,
    this.achievements = const [],
    this.settings = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'readingGoal': readingGoal,
      'booksCompletedThisYear': booksCompletedThisYear,
      'totalReadingTimeMinutes': totalReadingTimeMinutes,
      'joinDate': joinDate.millisecondsSinceEpoch,
      'achievements': achievements,
      'settings': settings,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      readingGoal: map['readingGoal'] ?? 12,
      booksCompletedThisYear: map['booksCompletedThisYear'] ?? 0,
      totalReadingTimeMinutes: map['totalReadingTimeMinutes'] ?? 0,
      joinDate: DateTime.fromMillisecondsSinceEpoch(map['joinDate'] ?? 0),
      achievements: List<String>.from(map['achievements'] ?? []),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  UserProfile copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? profileImageUrl,
    int? readingGoal,
    int? booksCompletedThisYear,
    int? totalReadingTimeMinutes,
    DateTime? joinDate,
    List<String>? achievements,
    Map<String, dynamic>? settings,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      readingGoal: readingGoal ?? this.readingGoal,
      booksCompletedThisYear: booksCompletedThisYear ?? this.booksCompletedThisYear,
      totalReadingTimeMinutes: totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      joinDate: joinDate ?? this.joinDate,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
    );
  }
}