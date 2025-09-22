import 'package:flutter/material.dart';

class BackgroundUtils {
  
  /// Create classic theme background
  static Widget createClassicBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF673AB7),
            Color(0xFF9C27B0),
            Color(0xFF3F51B5),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Ornamental circles
          Positioned(
            left: 50,
            top: 100,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE1BEE7).withOpacity(0.3),
                    const Color(0xFF673AB7).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 200,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE1BEE7).withOpacity(0.2),
                    const Color(0xFF673AB7).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          // Subtle pattern overlay
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: ClassicPatternPainter(),
          ),
          child,
        ],
      ),
    );
  }

  /// Create ocean theme background
  static Widget createOceanBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00BCD4),
            Color(0xFF0097A7),
            Color(0xFF006064),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating bubbles
          ...List.generate(15, (index) => Positioned(
            left: (index * 47 + 30) % 300,
            top: (index * 73 + 50) % 600,
            child: Container(
              width: (index % 3 + 1) * 15.0,
              height: (index % 3 + 1) * 15.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE0F7FA).withOpacity(0.6),
                    const Color(0xFF00BCD4).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          )),
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: OceanWavePainter(),
          ),
          child,
        ],
      ),
    );
  }

  /// Create forest theme background
  static Widget createForestBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
            Color(0xFF1B5E20),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Sunbeam effects
          ...List.generate(6, (index) => Positioned(
            left: (index * 120 + 50) % 400,
            top: (index * 80 + 80) % 500,
            child: Transform.rotate(
              angle: (index * 0.5),
              child: Container(
                width: 80,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC8E6C9).withOpacity(0.4),
                      const Color(0xFF4CAF50).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
          )),
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: LeafPatternPainter(),
          ),
          child,
        ],
      ),
    );
  }

  /// Create sunset theme background
  static Widget createSunsetBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9800),
            Color(0xFFF57C00),
            Color(0xFFE65100),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Sun
          Positioned(
            right: 100,
            top: 120,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFF3E0).withOpacity(0.8),
                    const Color(0xFFFFB74D).withOpacity(0.4),
                    const Color(0xFFFF9800).withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          // Cloud silhouettes
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: SunsetCloudPainter(),
          ),
          child,
        ],
      ),
    );
  }

  /// Create midnight sky theme background
  static Widget createMidnightSkyBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1A3A),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Starfield
          ...List.generate(30, (index) => Positioned(
            left: (index * 37.0 + 20) % 400,
            top: (index * 41.0 + 30) % 700,
            child: Container(
              width: (index % 3 + 1) * 2.0,
              height: (index % 3 + 1) * 2.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3 + (index % 4) * 0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          )),
          // Constellation lines
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: ConstellationPainter(),
          ),
          child,
        ],
      ),
    );
  }

  /// Create rose gold theme background
  static Widget createRoseGoldBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4A574),
            Color(0xFFE8B4CB),
            Color(0xFFB76E79),
            Color(0xFF8B5A83),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating particles
          ...List.generate(20, (index) => Positioned(
            left: (index * 43.0 + 15) % 350,
            top: (index * 67.0 + 20) % 650,
            child: Container(
              width: (index % 4 + 2) * 3.0,
              height: (index % 4 + 2) * 3.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFE5D9).withOpacity(0.8),
                    const Color(0xFFD4A574).withOpacity(0.3),
                  ],
                ),
              ),
            ),
          )),
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: RoseGoldShimmerPainter(),
          ),
          child,
        ],
      ),
    );
  }

  /// Create aurora theme background
  static Widget createAuroraBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
            Color(0xFF533A7B),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Aurora waves
          ...List.generate(5, (index) => Positioned(
            left: -50 + index * 30.0,
            top: 150.0 + index * 80.0,
            child: Transform.rotate(
              angle: index * 0.1,
              child: Container(
                width: 400 + index * 50.0,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [
                      [Color(0xFF5C5ADB), Color(0xFF3590F3), Color(0xFF1FCECB)][index % 3].withOpacity(0.4),
                      [Color(0xFF5C5ADB), Color(0xFF3590F3), Color(0xFF1FCECB)][index % 3].withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          )),
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: AuroraPatternPainter(),
          ),
          child,
        ],
      ),
    );
  }

  static Widget createBackgroundForTheme(String themeName, {required Widget child}) {
    switch (themeName) {
      case 'Ocean Breeze':
        return createOceanBackground(child: child);
      case 'Forest Dream':
        return createForestBackground(child: child);
      case 'Sunset Glow':
        return createSunsetBackground(child: child);
      case 'Midnight Sky':
        return createMidnightSkyBackground(child: child);
      case 'Rose Gold':
        return createRoseGoldBackground(child: child);
      case 'Aurora':
        return createAuroraBackground(child: child);
      case 'Classic':
      default:
        return createClassicBackground(child: child);
    }
  }
}

class ClassicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE1BEE7).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += 100) {
      for (double y = 0; y < size.height; y += 100) {
        canvas.drawRect(Rect.fromLTWH(x + 20, y + 20, 60, 60), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OceanWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4DD0E1).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double y = 100; y < size.height; y += 100) {
      path.reset();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 50) {
        path.quadraticBezierTo(x + 25, y - 20, x + 50, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LeafPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF81C784).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 80) {
      for (double y = 0; y < size.height; y += 80) {
        canvas.save();
        canvas.translate(x + 40, y + 40);
        canvas.rotate(0.5);
        canvas.drawOval(const Rect.fromLTWH(-8, -15, 16, 30), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SunsetCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFCC02).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Cloud shapes
    canvas.drawOval(Rect.fromLTWH(50, 150, 120, 50), paint);
    canvas.drawOval(Rect.fromLTWH(size.width - 170, 130, 140, 60), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ConstellationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw constellation lines
    final points = [
      [Offset(size.width * 0.2, size.height * 0.3), Offset(size.width * 0.35, size.height * 0.25)],
      [Offset(size.width * 0.35, size.height * 0.25), Offset(size.width * 0.4, size.height * 0.4)],
      [Offset(size.width * 0.6, size.height * 0.2), Offset(size.width * 0.75, size.height * 0.15)],
      [Offset(size.width * 0.75, size.height * 0.15), Offset(size.width * 0.8, size.height * 0.3)],
    ];

    for (final line in points) {
      canvas.drawLine(line[0], line[1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoseGoldShimmerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          const Color(0xFFFFE5D9).withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.55, size.width, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.85, size.width * 0.4, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.78, 0, size.height * 0.8)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuroraPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5C5ADB).withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw flowing aurora lines
    for (int i = 0; i < 6; i++) {
      final path = Path();
      final startY = size.height * 0.3 + i * 60.0;
      path.moveTo(0, startY);
      
      for (double x = 0; x < size.width; x += 30) {
        final offsetY = startY + (i % 2 == 0 ? 1 : -1) * 20 * (0.5 + 0.5 * (x / size.width));
        path.quadraticBezierTo(x + 15, offsetY - 15, x + 30, offsetY);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
