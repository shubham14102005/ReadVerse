import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/book.dart';

class BookCoverWidget extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final bool showShadow;

  const BookCoverWidget({
    super.key,
    required this.book,
    this.width = 120,
    this.height = 180,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildCoverImage(),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (book.coverImagePath != null && book.coverImagePath!.isNotEmpty) {
      if (book.coverImagePath!.endsWith('.svg')) {
        return SvgPicture.asset(
          book.coverImagePath!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => _buildDefaultCover(),
        );
      } else {
        return Image.asset(
          book.coverImagePath!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
        );
      }
    }
    
    return _buildDefaultCover();
  }

  Widget _buildDefaultCover() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getCategoryColors(book.id),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(),
            size: width * 0.3,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              book.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.08,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              book.author,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: width * 0.06,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    // Determine icon based on book content or category
    final title = book.title.toLowerCase();
    if (title.contains('guide') || title.contains('getting started')) {
      return Icons.help_outline;
    } else if (title.contains('adventure') || title.contains('great')) {
      return Icons.explore;
    } else if (title.contains('quantum') || title.contains('science')) {
      return Icons.science;
    } else if (title.contains('wellness') || title.contains('health')) {
      return Icons.favorite;
    } else if (title.contains('code') || title.contains('programming')) {
      return Icons.code;
    } else if (title.contains('mystery') || title.contains('detective')) {
      return Icons.search;
    } else if (title.contains('dragon') || title.contains('fantasy')) {
      return Icons.auto_stories;
    } else if (title.contains('romance') || title.contains('heart')) {
      return Icons.favorite;
    } else if (title.contains('business') || title.contains('entrepreneur')) {
      return Icons.business;
    } else {
      return Icons.menu_book;
    }
  }

  List<Color> _getCategoryColors(String bookId) {
    // Generate colors based on book ID for consistency
    switch (bookId) {
      case 'sample_1':
        return [const Color(0xFF673AB7), const Color(0xFF9C27B0)];
      case 'adventure_1':
        return [const Color(0xFFD32F2F), const Color(0xFFFF9800)];
      case 'science_1':
        return [const Color(0xFF1A237E), const Color(0xFF00BCD4)];
      case 'health_1':
        return [const Color(0xFF2E7D32), const Color(0xFF4CAF50)];
      case 'programming_1':
        return [const Color(0xFF0D47A1), const Color(0xFF42A5F5)];
      case 'mystery_1':
        return [const Color(0xFF263238), const Color(0xFF607D8B)];
      case 'fantasy_1':
        return [const Color(0xFF4A148C), const Color(0xFF9C27B0)];
      case 'romance_1':
        return [const Color(0xFFE91E63), const Color(0xFF880E4F)];
      case 'business_1':
        return [const Color(0xFF1B5E20), const Color(0xFF4CAF50)];
      default:
        return [const Color(0xFF6A1B9A), const Color(0xFF9C27B0)];
    }
  }
}

/// Small book cover for list items
class SmallBookCover extends StatelessWidget {
  final Book book;
  
  const SmallBookCover({super.key, required this.book});
  
  @override
  Widget build(BuildContext context) {
    return BookCoverWidget(
      book: book,
      width: 60,
      height: 80,
      showShadow: false,
    );
  }
}

/// Large book cover for featured display
class LargeBookCover extends StatelessWidget {
  final Book book;
  
  const LargeBookCover({super.key, required this.book});
  
  @override
  Widget build(BuildContext context) {
    return BookCoverWidget(
      book: book,
      width: 160,
      height: 240,
      showShadow: true,
    );
  }
}