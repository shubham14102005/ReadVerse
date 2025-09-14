import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/book_list_tile.dart';
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
        title: const Row(
          children: [
            Icon(
              Icons.menu_book,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'ReadVerse',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'profile') {
                    _navigateToProfile();
                  } else if (value == 'logout') {
                    _showLogoutDialog(authProvider);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      _getUserInitial(authProvider.user),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (bookProvider.books.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => bookProvider.loadBooks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookProvider.books.length,
              itemBuilder: (context, index) {
                final book = bookProvider.books[index];
                return BookListTile(
                  book: book,
                  onTap: () => _openBook(book),
                  onDelete: () => _showDeleteDialog(bookProvider, book),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _addBook(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
              const SizedBox(height: 32),
              Text(
                'No Books Yet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start your reading journey by adding your first book',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _addBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Your First Book',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  void _addBook() {
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

  void _navigateToProfile() {
    // Navigate to profile screen by changing the navigation index
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.setCurrentIndex(2); // Profile is at index 2
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getUserInitial(firebase_auth.User? user) {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.substring(0, 1).toUpperCase();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}
