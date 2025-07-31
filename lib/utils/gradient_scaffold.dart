import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool showPattern;
  final bool showKhandaSymbol;

  const GradientScaffold({
    super.key,
    this.appBar,
    this.drawer,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.showPattern = true,
    this.showKhandaSymbol = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      appBar: appBar,
      body: Stack(
        children: [
          // 🔹 Enhanced spiritual gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFDF8E1), // Warm cream - represents purity
                  Color(0xFFF5E6B8), // Light golden - represents divine light
                  Color(0xFFE8D5A3), // Deeper gold - represents wisdom
                  Color(0xFFD4C19C), // Warm beige - represents earth/grounding
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // 🎨 Subtle radial overlay for depth
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  const Color(0xFFFFE4A3).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 🔸 Optional geometric pattern
          if (showPattern)
            CustomPaint(
              painter: SacredPatternPainter(),
              size: Size.infinite,
            ),

          // 🕉️ Optional subtle Khanda symbol watermark
          if (showKhandaSymbol)
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.03,
                  child: Transform.scale(
                    scale: 3.0,
                    child: const Icon(
                      Icons.star_border_outlined, // Placeholder for Khanda symbol
                      size: 200,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ),
              ),
            ),

          // 📜 Content body
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

// 🎨 Sacred geometric pattern painter
class SacredPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.08) // Golden with low opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0xFFB8860B).withOpacity(0.15); // Darker gold for dots

    const spacing = 60.0;
    const radius = 25.0;

    // Draw interconnected circles pattern (representing unity and continuity)
    for (double y = radius; y < size.height; y += spacing) {
      for (double x = radius; x < size.width; x += spacing) {
        // Main circle
        canvas.drawCircle(Offset(x, y), radius, paint);

        // Small dot in center
        canvas.drawCircle(Offset(x, y), 2.0, dotPaint);

        // Draw connecting lines to create web pattern
        if (x + spacing < size.width) {
          canvas.drawLine(
            Offset(x + radius, y),
            Offset(x + spacing - radius, y),
            paint,
          );
        }
        if (y + spacing < size.height) {
          canvas.drawLine(
            Offset(x, y + radius),
            Offset(x, y + spacing - radius),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 🎨 Alternative lotus pattern painter for special pages
class LotusPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCD853F).withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const spacing = 100.0;
    const petalLength = 20.0;

    // Draw stylized lotus petals pattern
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        final center = Offset(x, y);

        // Draw 8 petals around center point
        for (int i = 0; i < 8; i++) {
          final angle = (i * 45) * (3.14159 / 180);
          final petalEnd = Offset(
            center.dx + petalLength * cos(angle),
            center.dy + petalLength * sin(angle),
          );

          final path = Path();
          path.moveTo(center.dx, center.dy);
          path.quadraticBezierTo(
            center.dx + (petalLength * 0.7) * cos(angle),
            center.dy + (petalLength * 0.7) * sin(angle),
            petalEnd.dx,
            petalEnd.dy,
          );
          path.quadraticBezierTo(
            center.dx + (petalLength * 0.3) * cos(angle),
            center.dy + (petalLength * 0.3) * sin(angle),
            center.dx,
            center.dy,
          );

          canvas.drawPath(path, paint);
        }
      }
    }
  }

  double cos(double angle) => math.cos(angle);
  double sin(double angle) => math.sin(angle);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 🎨 Text background overlay for better readability
class ReadingOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;

  const ReadingOverlay({
    super.key,
    required this.child,
    this.opacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withOpacity(opacity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE6D3A3).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4C19C).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// 🏛️ Sacred themed AppBar
class SacredAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const SacredAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF5E6B8),
            Color(0xFFE8D5A3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD4C19C),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        leading: leading,
        actions: actions,
        iconTheme: const IconThemeData(
          color: Color(0xFF8B4513),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 📖 Usage example for different sections
class NitnemTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color secondaryGold = Color(0xFFB8860B);
  static const Color textBrown = Color(0xFF8B4513);
  static const Color lightCream = Color(0xFFFFFDF7);
  static const Color warmBeige = Color(0xFFD4C19C);

  static const TextStyle headingStyle = TextStyle(
    color: textBrown,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: textBrown,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0.5,
  );

  static const TextStyle gurmukhiStyle = TextStyle(
    color: textBrown,
    fontSize: 18,
    height: 1.8,
    fontWeight: FontWeight.w500,
  );
}