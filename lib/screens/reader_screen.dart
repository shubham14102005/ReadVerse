import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../providers/book_provider_fixed.dart';
import '../providers/theme_provider.dart';
import '../models/book.dart';
import '../widgets/text_reader.dart';
import '../widgets/themed_background.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isFullScreen = false;
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _currentPage = _book.currentPage;
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (_book.fileType == 'pdf') {
        await _loadPDF();
      } else if (_book.fileType == 'epub') {
        await _loadEPUB();
      } else if (_book.fileType == 'txt') {
        await _loadText();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading book: $e';
      });
    }
  }

  Future<void> _loadPDF() async {
    // For PDF, we'll use flutter_pdfview
    setState(() {
      _totalPages = _book.totalPages;
    });
  }

  Future<void> _loadEPUB() async {
    setState(() {
      _totalPages = 100; // Default page count for EPUB
    });
  }

  Future<void> _loadText() async {
    // For text files, we'll navigate to our custom text reader immediately
    // Use a delay to ensure the current widget is fully built before navigation
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TextReader(
            filePath: _book.filePath,
            bookTitle: _book.title,
          ),
        ),
      );
    }
  }

  void _updateProgress() {
    if (_totalPages > 0) {
      final progress = _currentPage / _totalPages;
      final updatedBook = _book.copyWith(
        currentPage: _currentPage,
        totalPages: _totalPages,
        progress: progress,
        lastRead: DateTime.now(),
      );

      Provider.of<BookProviderFixed>(context, listen: false)
          .updateBookProgress(updatedBook, _currentPage);

      setState(() {
        _book = updatedBook;
      });
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: _isFullScreen
              ? null
              : AppBar(
                  title: Text(
                    _book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: themeProvider.currentFontFamily,
                    ),
                  ),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeProvider.currentGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _toggleFullScreen,
                      icon: const Icon(Icons.fullscreen),
                    ),
                  ],
                ),
          body: ThemedBackground(
            child: _buildReaderBody(),
          ),
          bottomNavigationBar: _isFullScreen ? null : _buildBottomBar(),
        );
      },
    );
  }

  Widget _buildReaderBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBook,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_book.fileType == 'pdf') {
      return _buildPDFViewer();
    } else if (_book.fileType == 'epub') {
      return _buildEPUBViewer();
    } else if (_book.fileType == 'txt') {
      // Text files should be handled by the TextReader widget
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return const Center(
      child: Text('Unsupported file format'),
    );
  }

  Widget _buildPDFViewer() {
    return PDFView(
      filePath: _book.filePath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
        _updateProgress();
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // Controller can be used for additional functionality
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = (page ?? 0) + 1; // ✅ fixed null-safety + type
        });
        _updateProgress();
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Error loading PDF: $error';
        });
      },
    );
  }

  Widget _buildEPUBViewer() {
    return const Center(
      child: Text(
        'EPUB Reader\n(Implementation in progress)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.currentGradient[0].withOpacity(0.1),
                themeProvider.currentGradient[1].withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              top: BorderSide(
                color: themeProvider.currentGradient[0].withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: TextStyle(
                      fontFamily: themeProvider.currentFontFamily,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode 
                          ? Colors.white 
                          : themeProvider.currentGradient[0],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeProvider.currentGradient.take(2).toList(),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(_book.progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _book.progress,
                  minHeight: 8,
                  backgroundColor: themeProvider.isDarkMode 
                      ? Colors.grey[700] 
                      : Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeProvider.currentGradient[0],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
