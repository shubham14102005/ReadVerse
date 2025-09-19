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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            book.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.book,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              book.author,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(book.dateAdded),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (book.progress > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(book.progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (book.progress > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: book.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite Button
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                book.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: book.isFavorite ? Colors.red : Colors.grey,
              ),
              tooltip: book.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            // More Options
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'favorite') {
                  onFavorite?.call();
                } else if (value == 'completed') {
                  onMarkCompleted?.call();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(
                        book.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(book.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
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
                      ),
                      const SizedBox(width: 8),
                      Text(book.progress >= 1.0 ? 'Mark as Incomplete' : 'Mark as Completed'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
