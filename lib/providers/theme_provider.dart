import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Colors.deepPurple;
  String _fontSize = 'Medium';

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  String get fontSize => _fontSize;

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

  void setFontSize(String size) {
    _fontSize = size;
    notifyListeners();
  }

  double get fontSizeMultiplier {
    switch (_fontSize) {
      case 'Small':
        return 0.85;
      case 'Medium':
        return 1.0;
      case 'Large':
        return 1.15;
      case 'Extra Large':
        return 1.3;
      default:
        return 1.0;
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
          fontSize: 20 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
      textTheme: _getTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  TextTheme _getTextTheme(Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize:
            (baseTextTheme.headlineLarge?.fontSize ?? 32) * fontSizeMultiplier,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize:
            (baseTextTheme.headlineMedium?.fontSize ?? 28) * fontSizeMultiplier,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize:
            (baseTextTheme.headlineSmall?.fontSize ?? 24) * fontSizeMultiplier,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize:
            (baseTextTheme.titleLarge?.fontSize ?? 22) * fontSizeMultiplier,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize:
            (baseTextTheme.titleMedium?.fontSize ?? 16) * fontSizeMultiplier,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize:
            (baseTextTheme.titleSmall?.fontSize ?? 14) * fontSizeMultiplier,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize:
            (baseTextTheme.bodyLarge?.fontSize ?? 16) * fontSizeMultiplier,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize:
            (baseTextTheme.bodyMedium?.fontSize ?? 14) * fontSizeMultiplier,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize:
            (baseTextTheme.bodySmall?.fontSize ?? 12) * fontSizeMultiplier,
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
