import 'package:flutter/material.dart';
import '../models/book.dart';

class ReadingStatsCard extends StatelessWidget {
  final List<Book> books;

  const ReadingStatsCard({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final totalBooks = books.length;
    final completedBooks = books.where((book) => book.progress >= 1.0).length;
    final readPages = books.fold(
        0, (sum, book) => sum + (book.totalPages * book.progress).round());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Reading Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
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
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Completed',
                  completedBooks.toString(),
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Pages Read',
                  readPages.toString(),
                  Icons.menu_book,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }
}
