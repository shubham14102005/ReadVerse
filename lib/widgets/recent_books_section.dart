import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/reader_screen.dart';

class RecentBooksSection extends StatelessWidget {
  final List<Book> books;

  const RecentBooksSection({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    // Get recent books (last 3 books by date added)
    final recentBooks = books.take(3).toList();

    if (recentBooks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Books',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentBooks.length,
            itemBuilder: (context, index) {
              final book = recentBooks[index];
              return Container(
                width: 200,
                margin: EdgeInsets.only(
                  right: index < recentBooks.length - 1 ? 16 : 0,
                ),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // Navigate to reader screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(book: book),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                book.fileType == 'pdf'
                                    ? Icons.picture_as_pdf
                                    : Icons.book,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.author,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          if (book.progress > 0) ...[
                            LinearProgressIndicator(
                              value: book.progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(book.progress * 100).toInt()}% complete',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
