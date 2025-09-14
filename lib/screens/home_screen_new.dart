import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_grid_tile.dart';
import '../widgets/reading_stats_card.dart';
import '../widgets/recent_books_section.dart';
import 'reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReadVerse'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddBookDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookProvider.books.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => bookProvider.loadBooks(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reading Stats Card
                  ReadingStatsCard(books: bookProvider.books),
                  const SizedBox(height: 24),

                  // Recent Books Section
                  RecentBooksSection(books: bookProvider.books),
                  const SizedBox(height: 24),

                  // All Books Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Books',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      TextButton(
                        onPressed: () => _showAllBooks(bookProvider.books),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Books Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: bookProvider.books.length > 6
                        ? 6
                        : bookProvider.books.length,
                    itemBuilder: (context, index) {
                      final book = bookProvider.books[index];
                      return BookGridTile(
                        book: book,
                        onTap: () => _openBook(book),
                        onDelete: () => _showDeleteDialog(bookProvider, book),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to ReadVerse!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your reading journey by adding your first book',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddBookDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Book'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBook(book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReaderScreen(book: book),
      ),
    );
  }

  void _showAddBookDialog() {
    Provider.of<BookProvider>(context, listen: false).addBook();
  }

  void _showDeleteDialog(BookProvider bookProvider, book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              bookProvider.deleteBook(book.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAllBooks(List books) {
    // This will be implemented when we add a dedicated all books page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Books view coming soon!')),
    );
  }
}
