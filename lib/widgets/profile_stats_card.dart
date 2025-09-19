import 'package:flutter/material.dart';
import '../models/book.dart';

class ProfileStatsCard extends StatelessWidget {
  final List<Book> books;

  const ProfileStatsCard({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final totalBooks = books.length;
    final completedBooks = books.where((book) => book.progress >= 1.0).length;
    final readingTime = _calculateReadingTime(books);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Books',
                    totalBooks.toString(),
                    Icons.library_books,
                    Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completed',
                    completedBooks.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Reading Time',
                    readingTime,
                    Icons.schedule,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: Container(), // Empty space for better layout
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _calculateReadingTime(List<Book> books) {
    // Estimate reading time based on pages (assuming 2 minutes per page)
    final totalPages = books.fold(
        0, (sum, book) => sum + (book.totalPages * book.progress).round());
    final totalMinutes = totalPages * 2;

    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    } else if (totalMinutes < 1440) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '${hours}h ${minutes}m';
    } else {
      final days = totalMinutes ~/ 1440;
      final hours = (totalMinutes % 1440) ~/ 60;
      return '${days}d ${hours}h';
    }
  }
}
