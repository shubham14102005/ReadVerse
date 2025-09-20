import 'package:flutter/material.dart';
import '../models/book.dart';

class BookListTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onMarkCompleted;

  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    this.onFavorite,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Book Cover
                _buildBookCover(context),
                const SizedBox(width: 16),
                // Book Info
                Expanded(
                  child: _buildBookInfo(context),
                ),
                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(BuildContext context) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Book Cover Image or Gradient Background
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.coverImagePath != null && book.coverImagePath!.isNotEmpty
                ? Image.asset(
                    book.coverImagePath!,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackCover(context);
                    },
                  )
                : _buildFallbackCover(context),
          ),
          // Progress indicator at bottom
          if (book.progress > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: book.progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackCover(BuildContext context) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          book.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.menu_book,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBookInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          book.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Author
        Text(
          book.author,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Progress Badge
        if (book.progress > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: book.progress >= 1.0 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: book.progress >= 1.0 
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    book.progress >= 1.0 ? Icons.check_circle : Icons.schedule,
                    size: 12,
                    color: book.progress >= 1.0 
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    book.progress >= 1.0 
                        ? 'Completed'
                        : '${(book.progress * 100).toInt()}%',
                    style: TextStyle(
                      color: book.progress >= 1.0 
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorite Button
        Container(
          decoration: BoxDecoration(
            color: book.isFavorite 
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onFavorite,
            icon: Icon(
              book.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: book.isFavorite ? Colors.red : Colors.grey[600],
              size: 20,
            ),
            tooltip: book.isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ),
        const SizedBox(height: 4),
        // More Options
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'favorite') {
                onFavorite?.call();
              } else if (value == 'completed') {
                onMarkCompleted?.call();
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
              size: 20,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(
                      book.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      book.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(
                      book.progress >= 1.0 ? Icons.check_circle : Icons.check_circle_outline,
                      color: book.progress >= 1.0 ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      book.progress >= 1.0 ? 'Mark as Incomplete' : 'Mark as Completed',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
