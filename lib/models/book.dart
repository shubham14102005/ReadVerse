class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String fileName;
  final String fileType;
  final int totalPages;
  final int currentPage;
  final DateTime dateAdded;
  final DateTime? lastRead;
  final double progress;
  final bool isFavorite;
  final int readingTimeMinutes;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.totalPages,
    this.currentPage = 0,
    required this.dateAdded,
    this.lastRead,
    this.progress = 0.0,
    this.isFavorite = false,
    this.readingTimeMinutes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'filePath': filePath,
      'fileName': fileName,
      'fileType': fileType,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'lastRead': lastRead?.millisecondsSinceEpoch,
      'progress': progress,
      'isFavorite': isFavorite,
      'readingTimeMinutes': readingTimeMinutes,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      filePath: map['filePath'] ?? '',
      fileName: map['fileName'] ?? '',
      fileType: map['fileType'] ?? '',
      totalPages: map['totalPages'] ?? 0,
      currentPage: map['currentPage'] ?? 0,
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] ?? 0),
      lastRead: map['lastRead'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastRead'])
          : null,
      progress: map['progress']?.toDouble() ?? 0.0,
      isFavorite: map['isFavorite'] ?? false,
      readingTimeMinutes: map['readingTimeMinutes'] ?? 0,
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    String? fileName,
    String? fileType,
    int? totalPages,
    int? currentPage,
    DateTime? dateAdded,
    DateTime? lastRead,
    double? progress,
    bool? isFavorite,
    int? readingTimeMinutes,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      dateAdded: dateAdded ?? this.dateAdded,
      lastRead: lastRead ?? this.lastRead,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
    );
  }
}
