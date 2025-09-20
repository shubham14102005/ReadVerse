/// Core Book Model - Represents the global book data (no user-specific data)
class CoreBook {
  final String id;
  final String title;
  final String author;
  final String? filePath;
  final String? fileName;
  final String fileType;
  final int totalPages;
  final String? coverUrl;
  final String? description;
  final String? genre;
  final DateTime? publishedDate;
  final bool isAssetBook;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? assetMetadata;

  const CoreBook({
    required this.id,
    required this.title,
    required this.author,
    this.filePath,
    this.fileName,
    required this.fileType,
    required this.totalPages,
    this.coverUrl,
    this.description,
    this.genre,
    this.publishedDate,
    this.isAssetBook = false,
    required this.createdAt,
    required this.updatedAt,
    this.assetMetadata,
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
      'coverUrl': coverUrl,
      'description': description,
      'genre': genre,
      'publishedDate': publishedDate?.toIso8601String(),
      'isAssetBook': isAssetBook,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assetMetadata': assetMetadata,
    };
  }

  factory CoreBook.fromMap(Map<String, dynamic> map) {
    return CoreBook(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      author: map['author']?.toString() ?? '',
      filePath: map['filePath']?.toString(),
      fileName: map['fileName']?.toString(),
      fileType: map['fileType']?.toString() ?? '',
      totalPages: _parseInt(map['totalPages']),
      coverUrl: map['coverUrl']?.toString(),
      description: map['description']?.toString(),
      genre: map['genre']?.toString(),
      publishedDate: map['publishedDate'] != null 
          ? DateTime.tryParse(map['publishedDate'].toString())
          : null,
      isAssetBook: _parseBool(map['isAssetBook']),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      assetMetadata: map['assetMetadata'] as Map<String, dynamic>?,
    );
  }

  CoreBook copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    String? fileName,
    String? fileType,
    int? totalPages,
    String? coverUrl,
    String? description,
    String? genre,
    DateTime? publishedDate,
    bool? isAssetBook,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? assetMetadata,
  }) {
    return CoreBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      totalPages: totalPages ?? this.totalPages,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      publishedDate: publishedDate ?? this.publishedDate,
      isAssetBook: isAssetBook ?? this.isAssetBook,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assetMetadata: assetMetadata ?? this.assetMetadata,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
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
      other is CoreBook && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CoreBook(id: $id, title: $title, author: $author)';
}