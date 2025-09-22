import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final String themeName;
  final List<Color> gradient;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.themeName,
    required this.gradient,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + index * 1000),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start all animations
    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        _buildGradientBackground(),
        // Theme-specific animated elements
        ..._buildThemeElements(),
        // Content
        widget.child,
      ],
    );
  }

  Widget _buildGradientBackground() {
    return AnimatedBuilder(
      animation: _animations[0],
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.gradient[0].withOpacity(0.8 + _animations[0].value * 0.2),
                if (widget.gradient.length > 1)
                  widget.gradient[1].withOpacity(0.6 + _animations[0].value * 0.2),
                if (widget.gradient.length > 2)
                  widget.gradient[2].withOpacity(0.4 + _animations[0].value * 0.2),
                widget.gradient[0].withOpacity(0.3 + _animations[0].value * 0.1),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildThemeElements() {
    switch (widget.themeName) {
      case 'Ocean Breeze':
        return _buildOceanElements();
      case 'Forest Dream':
        return _buildForestElements();
      case 'Sunset Glow':
        return _buildSunsetElements();
      case 'Midnight Sky':
        return _buildMidnightElements();
      case 'Rose Gold':
        return _buildRoseGoldElements();
      case 'Aurora':
        return _buildAuroraElements();
      case 'Classic':
      default:
        return _buildClassicElements();
    }
  }

  List<Widget> _buildOceanElements() {
    return [
      // Animated waves
      ..._buildAnimatedWaves(),
      // Floating bubbles
      ..._buildFloatingBubbles(),
      // Shimmer effect
      _buildShimmerEffect(),
    ];
  }

  List<Widget> _buildAnimatedWaves() {
    return List.generate(4, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          return Positioned(
            left: -100 + index * 80.0 + _animations[index % _animations.length].value * 50,
            top: 200.0 + index * 120.0,
            child: Transform.rotate(
              angle: _animations[index % _animations.length].value * 0.2,
              child: Container(
                width: 400,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4DD0E1).withOpacity(0.3),
                      const Color(0xFF00BCD4).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildFloatingBubbles() {
    return List.generate(15, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 10.0 + (index % 4) * 8.0;
          final baseLeft = (index * 31.0) % 350.0;
          final baseTop = (index * 41.0) % 600.0;
          
          return Positioned(
            left: baseLeft + _animations[index % _animations.length].value * 30,
            top: baseTop - _animations[index % _animations.length].value * 50,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4DD0E1).withOpacity(0.4),
                    const Color(0xFF00BCD4).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF4DD0E1).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _animations[0],
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: ShimmerEffectPainter(
              animation: _animations[0].value,
              color: const Color(0xFF4DD0E1),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildForestElements() {
    return [
      // Floating leaves
      ..._buildFloatingLeaves(),
      // Sunbeams
      ..._buildSunbeams(),
      // Particle dust
      ..._buildParticleDust(const Color(0xFF8BC34A)),
    ];
  }

  List<Widget> _buildFloatingLeaves() {
    return List.generate(12, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 25.0 + (index % 3) * 15.0;
          final baseLeft = (index * 67.0) % 350.0;
          final baseTop = (index * 89.0) % 600.0;
          
          return Positioned(
            left: baseLeft + _animations[index % _animations.length].value * 40 * math.sin(index.toDouble()),
            top: baseTop + _animations[index % _animations.length].value * 30,
            child: Transform.rotate(
              angle: _animations[index % _animations.length].value * math.pi * 2 + index,
              child: Container(
                width: size,
                height: size * 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF8BC34A).withOpacity(0.3),
                      const Color(0xFF689F38).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size / 2),
                    topRight: Radius.circular(size / 2),
                    bottomLeft: Radius.circular(size / 4),
                    bottomRight: Radius.circular(size / 4),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildSunbeams() {
    return List.generate(8, (index) {
      return AnimatedBuilder(
        animation: _animations[1],
        builder: (context, child) {
          final angle = (index * math.pi * 2) / 8;
          return Positioned(
            top: 100,
            right: 100,
            child: Transform.rotate(
              angle: angle + _animations[1].value * 0.5,
              child: Container(
                width: 120 + _animations[1].value * 30,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF59D).withOpacity(0.4),
                      const Color(0xFF8BC34A).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildSunsetElements() {
    return [
      // Animated sun
      _buildAnimatedSun(),
      // Floating particles
      ..._buildParticleDust(const Color(0xFFFF9800)),
      // Cloud silhouettes
      ..._buildFloatingClouds(),
    ];
  }

  Widget _buildAnimatedSun() {
    return AnimatedBuilder(
      animation: _animations[0],
      builder: (context, child) {
        return Positioned(
          right: 80,
          top: 80 + _animations[0].value * 20,
          child: Container(
            width: 100 + _animations[0].value * 20,
            height: 100 + _animations[0].value * 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFF3E0).withOpacity(0.8),
                  const Color(0xFFFFB74D).withOpacity(0.6),
                  const Color(0xFFFF9800).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.4),
                  blurRadius: 20 + _animations[0].value * 10,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingClouds() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _animations[index + 1],
        builder: (context, child) {
          return Positioned(
            left: (index * 150.0) % 300.0 + _animations[index + 1].value * 20,
            top: 150 + index * 80.0,
            child: Container(
              width: 80 + index * 20.0,
              height: 40 + index * 10.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFCC02).withOpacity(0.3),
                    const Color(0xFFFF9800).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildMidnightElements() {
    return [
      // Twinkling stars
      ..._buildTwinklingStars(),
      // Constellation lines
      _buildConstellationLines(),
      // Shooting stars
      ..._buildShootingStars(),
    ];
  }

  List<Widget> _buildTwinklingStars() {
    return List.generate(25, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 2.0 + (index % 4).toDouble();
          final opacity = 0.3 + _animations[index % _animations.length].value * 0.7;
          
          return Positioned(
            left: (index * 23.0) % 350.0,
            top: (index * 37.0) % 600.0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(opacity),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(opacity * 0.5),
                    blurRadius: size * 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildConstellationLines() {
    return AnimatedBuilder(
      animation: _animations[2],
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: ConstellationPainter(
              animation: _animations[2].value,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildShootingStars() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _animations[index + 3],
        builder: (context, child) {
          return Positioned(
            left: -100 + _animations[index + 3].value * 500,
            top: 50 + index * 150.0,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 60,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildRoseGoldElements() {
    return [
      // Shimmering particles
      ..._buildShimmeringParticles(),
      // Gradient waves
      ..._buildGradientWaves(),
      // Floating hearts
      ..._buildFloatingHearts(),
    ];
  }

  List<Widget> _buildShimmeringParticles() {
    return List.generate(20, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 3.0 + (index % 5) * 2.0;
          final baseLeft = (index * 43.0 + 15) % 350;
          final baseTop = (index * 67.0 + 20) % 650;
          
          return Positioned(
            left: baseLeft + _animations[index % _animations.length].value * 20,
            top: baseTop - _animations[index % _animations.length].value * 30,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFE5D9).withOpacity(0.8),
                    const Color(0xFFD4A574).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildGradientWaves() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Positioned(
            left: -50 + index * 40.0,
            top: 250.0 + index * 100.0,
            child: Transform.rotate(
              angle: _animations[index].value * 0.3,
              child: Container(
                width: 350 + index * 50.0,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE8B4CB).withOpacity(0.3),
                      const Color(0xFFD4A574).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildFloatingHearts() {
    return List.generate(8, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 15.0 + (index % 3) * 5.0;
          return Positioned(
            left: (index * 50.0) % 300.0 + _animations[index % _animations.length].value * 30,
            top: 400 + index * 40.0 - _animations[index % _animations.length].value * 60,
            child: CustomPaint(
              size: Size(size, size),
              painter: HeartPainter(
                color: const Color(0xFFE8B4CB).withOpacity(0.4),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildAuroraElements() {
    return [
      // Aurora waves
      ..._buildAuroraWaves(),
      // Particle streams
      ..._buildParticleStreams(),
      // Energy orbs
      ..._buildEnergyOrbs(),
    ];
  }

  List<Widget> _buildAuroraWaves() {
    return List.generate(5, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final colors = [
            const Color(0xFF5C5ADB),
            const Color(0xFF3590F3),
            const Color(0xFF1FCECB),
          ];
          
          return Positioned(
            left: -50 + index * 30.0 + _animations[index % _animations.length].value * 40,
            top: 150.0 + index * 80.0,
            child: Transform.rotate(
              angle: _animations[index % _animations.length].value * 0.2 + index * 0.1,
              child: Container(
                width: 400 + index * 50.0,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      colors[index % colors.length].withOpacity(0.4),
                      colors[index % colors.length].withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildParticleStreams() {
    return List.generate(30, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final colors = [
            const Color(0xFF5C5ADB),
            const Color(0xFF3590F3),
            const Color(0xFF1FCECB),
          ];
          
          return Positioned(
            left: (index * 13.0) % 350.0,
            top: -20 + _animations[index % _animations.length].value * 700,
            child: Container(
              width: 2,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors[index % colors.length].withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildEnergyOrbs() {
    return List.generate(5, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 20.0 + _animations[index % _animations.length].value * 15;
          final colors = [
            const Color(0xFF5C5ADB),
            const Color(0xFF3590F3),
            const Color(0xFF1FCECB),
          ];
          
          return Positioned(
            left: (index * 80.0) % 300.0,
            top: 200 + index * 100.0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors[index % colors.length].withOpacity(0.6),
                    colors[index % colors.length].withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildClassicElements() {
    return [
      // Geometric patterns
      ..._buildGeometricPatterns(),
      // Floating orbs
      ..._buildFloatingOrbs(),
      // Grid overlay
      _buildGridOverlay(),
    ];
  }

  List<Widget> _buildGeometricPatterns() {
    return List.generate(6, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 40.0 + index * 10.0;
          return Positioned(
            left: (index * 80.0) % 300.0 + _animations[index % _animations.length].value * 20,
            top: 100 + index * 90.0,
            child: Transform.rotate(
              angle: _animations[index % _animations.length].value * math.pi * 2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(index.isEven ? size / 2 : 8),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildFloatingOrbs() {
    return List.generate(10, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 15.0 + (index % 4) * 8.0;
          final baseLeft = (index * 37.0) % 350.0;
          final baseTop = (index * 47.0) % 600.0;
          
          return Positioned(
            left: baseLeft + _animations[index % _animations.length].value * 30,
            top: baseTop - _animations[index % _animations.length].value * 40,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF673AB7).withOpacity(0.4),
                    const Color(0xFF9C27B0).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildGridOverlay() {
    return AnimatedBuilder(
      animation: _animations[0],
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: GridOverlayPainter(
              animation: _animations[0].value,
              color: const Color(0xFF9C27B0),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticleDust(Color color) {
    return List.generate(25, (index) {
      return AnimatedBuilder(
        animation: _animations[index % _animations.length],
        builder: (context, child) {
          final size = 1.5 + (index % 3) * 1.0;
          final baseLeft = (index * 19.0) % 350.0;
          final baseTop = (index * 29.0) % 600.0;
          
          return Positioned(
            left: baseLeft + _animations[index % _animations.length].value * 15,
            top: baseTop - _animations[index % _animations.length].value * 25,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.4),
              ),
            ),
          );
        },
      );
    });
  }
}

// Custom Painters for special effects
class ShimmerEffectPainter extends CustomPainter {
  final double animation;
  final Color color;

  ShimmerEffectPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + animation * 2, -1.0),
        end: Alignment(1.0 + animation * 2, 1.0),
        colors: [
          Colors.transparent,
          color.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConstellationPainter extends CustomPainter {
  final double animation;

  ConstellationPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2 + animation * 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create heart shape
    path.moveTo(size.width / 2, size.height * 0.3);
    path.cubicTo(
      size.width * 0.2, size.height * 0.1,
      0, size.height * 0.1,
      0, size.height * 0.3,
    );
    path.cubicTo(
      0, size.height * 0.5,
      size.width / 2, size.height * 0.8,
      size.width / 2, size.height * 0.8,
    );
    path.cubicTo(
      size.width / 2, size.height * 0.8,
      size.width, size.height * 0.5,
      size.width, size.height * 0.3,
    );
    path.cubicTo(
      size.width, size.height * 0.1,
      size.width * 0.8, size.height * 0.1,
      size.width / 2, size.height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridOverlayPainter extends CustomPainter {
  final double animation;
  final Color color;

  GridOverlayPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1 + animation * 0.1)
      ..strokeWidth = 1;

    const spacing = 50.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}