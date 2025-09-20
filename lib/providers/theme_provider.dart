import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  Color _primaryColor = Colors.deepPurple;
  String _fontStyle = 'Default';
  String _selectedTheme = 'Classic';
  String _backgroundImage = '';

  // Beautiful font styles
  final Map<String, Map<String, dynamic>> _fontStyles = {
    'Default': {
      'fontFamily': null,
      'fontSize': 16.0,
      'description': 'System default font',
    },
    'Modern Sans': {
      'fontFamily': 'sans-serif',
      'fontSize': 16.0,
      'description': 'Clean and modern',
    },
    'Handwritten': {
      'fontFamily': 'cursive',
      'fontSize': 16.0,
      'description': 'Personal and artistic',
    },
  };

  // Beautiful theme options
  final Map<String, Map<String, dynamic>> _themes = {
    'Classic': {
      'primaryColor': Colors.deepPurple,
      'background': 'assets/images/classic_bg.jpg',
      'gradient': [Color(0xFF673AB7), Color(0xFF9C27B0)],
      'description': 'Classic elegance',
    },
    'Ocean Breeze': {
      'primaryColor': Colors.cyan,
      'background': 'assets/images/ocean_bg.jpg',
      'gradient': [Color(0xFF00BCD4), Color(0xFF0097A7), Color(0xFF006064)],
      'description': 'Cool ocean vibes',
    },
    'Forest Dream': {
      'primaryColor': Colors.green,
      'background': 'assets/images/forest_bg.jpg',
      'gradient': [Color(0xFF4CAF50), Color(0xFF2E7D32), Color(0xFF1B5E20)],
      'description': 'Natural forest feel',
    },
    'Sunset Glow': {
      'primaryColor': Colors.orange,
      'background': 'assets/images/sunset_bg.jpg',
      'gradient': [Color(0xFFFF9800), Color(0xFFF57C00), Color(0xFFE65100)],
      'description': 'Warm sunset colors',
    },
    'Midnight Sky': {
      'primaryColor': Colors.indigo,
      'background': 'assets/images/night_bg.jpg',
      'gradient': [Color(0xFF3F51B5), Color(0xFF283593), Color(0xFF1A237E)],
      'description': 'Deep night sky',
    },
    'Rose Gold': {
      'primaryColor': Color(0xFFE91E63),
      'background': 'assets/images/rose_bg.jpg',
      'gradient': [Color(0xFFE91E63), Color(0xFFC2185B), Color(0xFF880E4F)],
      'description': 'Elegant rose tones',
    },
    'Aurora': {
      'primaryColor': Color(0xFF9C27B0),
      'background': 'assets/images/aurora_bg.jpg',
      'gradient': [Color(0xFF9C27B0), Color(0xFF673AB7), Color(0xFF3F51B5)],
      'description': 'Magical aurora lights',
    },
  };

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  String get fontStyle => _fontStyle;
  String get selectedTheme => _selectedTheme;
  String get backgroundImage => _backgroundImage;
  Map<String, Map<String, dynamic>> get themes => _themes;
  Map<String, Map<String, dynamic>> get fontStyles => _fontStyles;
  List<Color> get currentGradient => _themes[_selectedTheme]?['gradient'] ?? [_primaryColor, _primaryColor];
  String? get currentFontFamily => _fontStyles[_fontStyle]?['fontFamily'];
  double get currentFontSize => _fontStyles[_fontStyle]?['fontSize'] ?? 16.0;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setFontStyle(String style) {
    if (_fontStyles.containsKey(style)) {
      _fontStyle = style;
      notifyListeners();
    }
  }

  void setTheme(String themeName) {
    if (_themes.containsKey(themeName)) {
      _selectedTheme = themeName;
      _primaryColor = _themes[themeName]!['primaryColor'];
      _backgroundImage = _themes[themeName]!['background'] ?? '';
      notifyListeners();
    }
  }


  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: _colorToMaterialColor(_primaryColor),
      primaryColor: _primaryColor,
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: _getTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: currentFontFamily,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: _colorToMaterialColor(_primaryColor),
      primaryColor: _primaryColor,
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dialogBackgroundColor: const Color(0xFF1E1E1E),
      textTheme: _getTextTheme(Brightness.dark),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 8,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: currentFontFamily,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      dividerColor: Colors.grey[700],
      iconTheme: IconThemeData(color: Colors.grey[300]),
    );
  }

  TextTheme _getTextTheme(Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize + 16, // Larger for headlines
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize + 12,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize + 8,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize + 6,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize + 2,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize + 1,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: currentFontFamily,
        fontSize: currentFontSize - 2,
      ),
    );
  }

  MaterialColor _colorToMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round() & 0xff;
    final int g = (color.g * 255.0).round() & 0xff;
    final int b = (color.b * 255.0).round() & 0xff;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}
