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
  final bool isAssetBook;
  final String? coverImagePath;

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
    this.isAssetBook = false,
    this.coverImagePath,
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
      'isAssetBook': isAssetBook,
      'coverImagePath': coverImagePath,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      author: map['author']?.toString() ?? '',
      filePath: map['filePath']?.toString() ?? '',
      fileName: map['fileName']?.toString() ?? '',
      fileType: map['fileType']?.toString() ?? '',
      totalPages: _parseInt(map['totalPages']),
      currentPage: _parseInt(map['currentPage']),
      dateAdded: DateTime.fromMillisecondsSinceEpoch(_parseInt(map['dateAdded'])),
      lastRead: map['lastRead'] != null
          ? DateTime.fromMillisecondsSinceEpoch(_parseInt(map['lastRead']))
          : null,
      progress: _parseDouble(map['progress']),
      isFavorite: _parseBool(map['isFavorite']),
      readingTimeMinutes: _parseInt(map['readingTimeMinutes']),
      isAssetBook: _parseBool(map['isAssetBook']),
      coverImagePath: map['coverImagePath']?.toString(),
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
    bool? isAssetBook,
    String? coverImagePath,
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
      isAssetBook: isAssetBook ?? this.isAssetBook,
      coverImagePath: coverImagePath ?? this.coverImagePath,
    );
  }
}
