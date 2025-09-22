import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider_fixed.dart';
import 'providers/navigation_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_profile_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase fails to initialize, continue without it
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running in demo mode without Firebase');
  }

  runApp(const ReadVerseApp());
}

class ReadVerseApp extends StatelessWidget {
  const ReadVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProviderFixed()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final themeProvider = ThemeProvider();
            // Initialize theme settings from SharedPreferences
            themeProvider.initializeThemeSettings();
            return themeProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ReadVerse',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/auth': (context) => const AuthScreen(),
              '/main': (context) => const MainNavigation(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
