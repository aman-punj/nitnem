import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/design_system/tokens/colors.dart';

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
    this.showPattern = false,
    this.showKhandaSymbol = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      appBar: appBar,
      backgroundColor: SacredColors.backgroundBlack,
      body: Stack(
        children: [
          // 🔹 AMOLED base background with subtle atmospheric gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: SacredColors.backgroundBlack,
                gradient: LinearGradient(
                  colors: [
                    SacredColors.backgroundDeep,
                    SacredColors.backgroundBlack,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 🎨 Ultra-subtle radial glow for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, 0.9), // Low center glow
                  radius: 1.4,
                  colors: [
                    SacredColors.primaryAccent.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 🔸 Optional geometric pattern (restrained)
          if (showPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: SacredPatternPainter(),
              ),
            ),

          // 🕉️ Optional subtle Khanda symbol watermark
          if (showKhandaSymbol)
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.02,
                  child: Transform.scale(
                    scale: 2.5,
                    child: const Icon(
                      Icons.star_border_outlined, // Placeholder for Khanda symbol
                      size: 200,
                      color: SacredColors.primaryAccent,
                    ),
                  ),
                ),
              ),
            ),

          // 📜 Content body
          SafeArea(top: false,child: body),
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
      ..color = SacredColors.primaryAccent.withValues(alpha: 0.02) // Near invisible
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5; // Thinner lines

    final dotPaint = Paint()
      ..color = SacredColors.primaryAccent.withValues(alpha: 0.04);

    const spacing = 60.0;
    const radius = 20.0; // Slightly smaller

    // Draw interconnected circles pattern (representing unity and continuity)
    for (double y = radius; y < size.height; y += spacing) {
      for (double x = radius; x < size.width; x += spacing) {
        // Main circle
        canvas.drawCircle(Offset(x, y), radius, paint);

        // Small dot in center
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);

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
      ..color = SacredColors.primaryAccent.withValues(alpha: 0.015)
      ..style = PaintingStyle.fill;

    const spacing = 120.0;
    const petalLength = 15.0;

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
    this.opacity = 0.95, // Higher opacity for dark surfaces
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SacredColors.surfacePrimary.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SacredColors.borderGold.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
      decoration: BoxDecoration(
        color: SacredColors.backgroundBlack.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: SacredColors.borderGold.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: SacredColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        leading: leading,
        actions: actions,
        iconTheme: const IconThemeData(
          color: SacredColors.primaryAccent,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

