import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/themed_background.dart';

class TextReader extends StatefulWidget {
  final String filePath;
  final String bookTitle;

  const TextReader({
    super.key,
    required this.filePath,
    required this.bookTitle,
  });

  @override
  State<TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<TextReader> {
  String _content = '';
  bool _isLoading = true;
  double _fontSize = 16.0;
  String _readingTheme = 'Default';
  bool _isFullScreen = false;
  
  // Page navigation
  List<String> _pages = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final int _wordsPerPage = 300; // Approximate words per page
  List<ScrollController> _scrollControllers = [];

  final Map<String, Map<String, dynamic>> _readingThemes = {
    'Default': {
      'backgroundColor': null, // Will use app theme
      'textColor': null, // Will use app theme
      'description': 'Follow app theme',
    },
    'Night': {
      'backgroundColor': Color(0xFF1A1A1A),
      'textColor': Color(0xFF4A9EFF),
      'description': 'Blue light filtered - Easy on eyes',
    },
  };

  // Nature-inspired gradients for different app themes
  LinearGradient _getNatureGradient(String appTheme) {
    switch (appTheme) {
      case 'Ocean Breeze':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF89CFF0), // Sky blue
            Color(0xFF0077BE), // Ocean blue
            Color(0xFF003F5C), // Deep ocean
          ],
        );
      case 'Forest Dream':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF90EE90), // Light green
            Color(0xFF228B22), // Forest green
            Color(0xFF013220), // Deep forest
          ],
        );
      case 'Sunset Glow':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFD700), // Golden
            Color(0xFFFF8C00), // Dark orange
            Color(0xFFFF4500), // Red orange
          ],
        );
      case 'Midnight Sky':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF191970), // Midnight blue
            Color(0xFF000080), // Navy
            Color(0xFF000033), // Very dark blue
          ],
        );
      case 'Rose Gold':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFC0CB), // Pink
            Color(0xFFDB7093), // Pale violet red
            Color(0xFF8B1538), // Dark red
          ],
        );
      case 'Aurora':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9370DB), // Medium purple
            Color(0xFF4B0082), // Indigo
            Color(0xFF483D8B), // Dark slate blue
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE6E6FA), // Lavender
            Color(0xFF9370DB), // Medium purple
            Color(0xFF663399), // Rebecca purple
          ],
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBookContent();
  }

  Future<void> _loadBookContent() async {
    try {
      final content = await rootBundle.loadString(widget.filePath);
      _splitIntoPages(content);
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading book content: $e';
        _isLoading = false;
      });
    }
  }
  
  void _splitIntoPages(String content) {
    // Clean up the content first
    final cleanedContent = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    final words = cleanedContent.split(' ');
    final List<String> pages = [];
    
    for (int i = 0; i < words.length; i += _wordsPerPage) {
      final endIndex = (i + _wordsPerPage < words.length) ? i + _wordsPerPage : words.length;
      final pageWords = words.sublist(i, endIndex);
      final pageContent = pageWords.join(' ');
      pages.add(pageContent);
    }
    
    _pages = pages;
    
    // Create scroll controllers for each page
    _scrollControllers.clear();
    for (int i = 0; i < _pages.length; i++) {
      _scrollControllers.add(ScrollController());
    }
  }
  
  void _goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _pages.length) {
      setState(() {
        _currentPage = pageIndex;
      });
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
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

  Color _getCurrentBackgroundColor(ThemeProvider themeProvider) {
    final themeConfig = _readingThemes[_readingTheme]!;
    if (themeConfig['backgroundColor'] != null) {
      return themeConfig['backgroundColor'];
    }
    return themeProvider.isDarkMode 
        ? const Color(0xFF121212)
        : Colors.white;
  }

  Color _getCurrentTextColor(ThemeProvider themeProvider) {
    final themeConfig = _readingThemes[_readingTheme]!;
    if (themeConfig['textColor'] != null) {
      return themeConfig['textColor'];
    }
    return themeProvider.isDarkMode 
        ? Colors.white
        : Colors.black87;
  }


  Future<void> _showReaderSettings() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.currentGradient[0].withOpacity(0.1),
                        themeProvider.currentGradient[1].withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: themeProvider.isDarkMode 
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: themeProvider.currentGradient.take(2).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Reading Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: themeProvider.currentFontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Font Size
                            _buildSettingSection(
                              'Font Size',
                              Icons.text_fields,
                              themeProvider,
                              Row(
                                children: [
                                  const Icon(Icons.text_decrease, size: 16),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: themeProvider.currentGradient[0],
                                        thumbColor: themeProvider.currentGradient[0],
                                        inactiveTrackColor: Colors.grey[300],
                                      ),
                                      child: Slider(
                                        value: _fontSize,
                                        min: 12.0,
                                        max: 28.0,
                                        divisions: 16,
                                        onChanged: (value) {
                                          setModalState(() => _fontSize = value);
                                          setState(() => _fontSize = value);
                                        },
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.text_increase, size: 16),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: themeProvider.currentGradient[0].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _fontSize.round().toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.currentGradient[0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Reading Themes
                            _buildSettingSection(
                              'Reading Theme',
                              Icons.color_lens,
                              themeProvider,
                              Column(
                                children: _readingThemes.entries.map((entry) {
                                  return _buildReadingThemeOption(
                                    entry.key,
                                    entry.value,
                                    themeProvider,
                                    setModalState,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Done Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: themeProvider.currentGradient.take(2).toList(),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSettingSection(String title, IconData icon, ThemeProvider themeProvider, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: themeProvider.currentGradient[0],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                fontFamily: themeProvider.currentFontFamily,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildReadingThemeOption(
    String themeName,
    Map<String, dynamic> themeData,
    ThemeProvider themeProvider,
    StateSetter setModalState,
  ) {
    final isSelected = _readingTheme == themeName;
    final bgColor = themeData['backgroundColor'] ?? 
        (themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = themeData['textColor'] ?? 
        (themeProvider.isDarkMode ? Colors.white : Colors.black87);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          setModalState(() => _readingTheme = themeName);
          setState(() => _readingTheme = themeName);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? themeProvider.currentGradient[0] 
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeName,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                        fontFamily: themeProvider.currentFontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeData['description'] ?? '',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: themeProvider.currentGradient[0],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final readingBackgroundColor = _getCurrentBackgroundColor(themeProvider);
        final textColor = _getCurrentTextColor(themeProvider);
        
        return PopScope(
          canPop: true,
          child: Scaffold(
            // Keep app theme for scaffold background
            backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
            appBar: _isFullScreen
                ? null
                : AppBar(
                    title: Text(
                      widget.bookTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: themeProvider.currentFontFamily,
                        color: Colors.white,
                      ),
                    ),
                    // Keep app theme gradient for app bar
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.currentGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: _toggleFullScreen,
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: _showReaderSettings,
                      ),
                    ],
                  ),
            body: _isLoading
                ? Container(
                    color: const Color(0xFF1A1A1A),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue[400],
                      ),
                    ),
                  )
                : Container(
                    // Dark background color
                    color: const Color(0xFF1A1A1A),
                    child: Stack(
                      children: [
                        // Page View
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _isFullScreen ? 20 : 30,
                                vertical: _isFullScreen ? 20 : 40,
                              ),
                              child: Column(
                                children: [
                                  // Page Number at top
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: Text(
                                        'Page ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor.withOpacity(0.7),
                                          fontFamily: themeProvider.currentFontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Scrollable page content
                                  Expanded(
                                    child: Scrollbar(
                                      controller: _scrollControllers.isNotEmpty && index < _scrollControllers.length 
                                          ? _scrollControllers[index] 
                                          : null,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      radius: const Radius.circular(8),
                                      thickness: 8,
                                      child: SingleChildScrollView(
                                        controller: _scrollControllers.isNotEmpty && index < _scrollControllers.length 
                                            ? _scrollControllers[index] 
                                            : null,
                                        padding: const EdgeInsets.only(right: 16),
                                        child: SelectableText(
                                          _pages[index],
                                          style: TextStyle(
                                            fontSize: _fontSize,
                                            color: textColor,
                                            height: 1.8,
                                            letterSpacing: 0.3,
                                            wordSpacing: 0.5,
                                            fontFamily: themeProvider.currentFontFamily,
                                          ),
                                          // Enhanced text selection
                                          selectionControls: MaterialTextSelectionControls(),
                                          showCursor: true,
                                          cursorColor: Colors.blue[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Page Number at bottom
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: Text(
                                        '${index + 1} of ${_pages.length}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withOpacity(0.6),
                                          fontFamily: themeProvider.currentFontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        // Page Navigation Buttons
                        if (!_isFullScreen) ...[
                          // Previous Page Button
                          if (_currentPage > 0)
                            Positioned(
                              left: 20,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400]!.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                                    onPressed: _previousPage,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Next Page Button
                          if (_currentPage < _pages.length - 1)
                            Positioned(
                              right: 20,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400]!.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 30),
                                    onPressed: _nextPage,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        
                        // Page Progress Bar at Bottom
                        if (_pages.length > 1)
                          Positioned(
                            bottom: _isFullScreen ? 20 : 40,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800]!.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.blue[400]!.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Page ${_currentPage + 1} of ${_pages.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: Colors.blue[400],
                                          thumbColor: Colors.blue[400],
                                          inactiveTrackColor: Colors.grey[600],
                                          trackHeight: 3,
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                        ),
                                        child: Slider(
                                          value: _currentPage.toDouble(),
                                          max: (_pages.length - 1).toDouble(),
                                          divisions: _pages.length - 1,
                                          onChanged: (value) {
                                            _goToPage(value.round());
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${((_currentPage + 1) / _pages.length * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
            floatingActionButton: _isFullScreen
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.blue[400]!.withOpacity(0.8),
                        onPressed: _showReaderSettings,
                        heroTag: "settings",
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.blue[400]!.withOpacity(0.8),
                        onPressed: _toggleFullScreen,
                        heroTag: "fullscreen",
                        child: const Icon(Icons.fullscreen_exit, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      // Page navigation in fullscreen
                      if (_currentPage > 0)
                        FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.blue[400]!.withOpacity(0.8),
                          onPressed: _previousPage,
                          heroTag: "prev",
                          child: const Icon(Icons.chevron_left, color: Colors.white),
                        ),
                      if (_currentPage > 0) const SizedBox(height: 8),
                      if (_currentPage < _pages.length - 1)
                        FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.blue[400]!.withOpacity(0.8),
                          onPressed: _nextPage,
                          heroTag: "next",
                          child: const Icon(Icons.chevron_right, color: Colors.white),
                        ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}