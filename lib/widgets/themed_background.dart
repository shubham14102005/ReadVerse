import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;
  
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        // If background image is set, use it with overlay
        if (themeProvider.backgroundImage.isNotEmpty) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(themeProvider.backgroundImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(themeProvider.isDarkMode ? 0.7 : 0.3),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.currentGradient[0].withOpacity(0.1),
                    themeProvider.currentGradient[1].withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: child,
            ),
          );
        }
        
        // If no background image, use gradient or solid color
        final gradient = themeProvider.currentGradient;
        return Container(
          decoration: BoxDecoration(
            gradient: themeProvider.isDarkMode
                ? LinearGradient(
                    colors: [
                      const Color(0xFF121212),
                      const Color(0xFF1E1E1E),
                      gradient[0].withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: gradient.length >= 3
                        ? [
                            gradient[0].withOpacity(0.05),
                            gradient[1].withOpacity(0.03),
                            gradient[2].withOpacity(0.01),
                          ]
                        : [
                            gradient[0].withOpacity(0.05),
                            gradient[1].withOpacity(0.02),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: child,
        );
      },
    );
  }
}

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  const ThemedCard({
    super.key, 
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode 
                ? const Color(0xFF1E1E1E).withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: themeProvider.isDarkMode
                ? Border.all(color: Colors.grey[800]!, width: 0.5)
                : null,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        );
      },
    );
  }
}

class ThemedGradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  
  const ThemedGradientContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final gradient = themeProvider.currentGradient;
        return Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.isDarkMode
                  ? gradient.length >= 3
                      ? [
                          gradient[0].withOpacity(0.4),
                          gradient[1].withOpacity(0.2),
                          gradient[2].withOpacity(0.1),
                        ]
                      : [
                          gradient[0].withOpacity(0.3),
                          gradient[1].withOpacity(0.1),
                        ]
                  : gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}