import 'package:flutter/material.dart';

import '../models/drawer_item.dart';
import '../core/design_system/tokens/colors.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.onItemSelected});

  final Function(DrawerItem) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: SacredColors.backgroundBlack,
      child: Container(
        decoration: const BoxDecoration(
          color: SacredColors.backgroundBlack,
          gradient: LinearGradient(
            colors: [
              SacredColors.backgroundDeep,
              SacredColors.backgroundBlack,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Subtle background pattern (highly restrained)
            Positioned.fill(
              child: CustomPaint(
                painter: DrawerPatternPainter(),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Drawer Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Khanda Avatar with sacred styling
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                SacredColors.primaryAccent,
                                SacredColors.accentSoft,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 32,
                            backgroundColor: SacredColors.surfacePrimary,
                            child: CircleAvatar(
                              radius: 29,
                              backgroundImage: AssetImage('assets/images/khanda_image.png'),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Bani Sagar',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: SacredColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Decorative divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                SacredColors.primaryAccent.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Drawer Items with enhanced styling
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: drawerItems.map((item) => _buildDrawerItem(item)).toList(),
                    ),
                  ),

                  // Footer with enhanced styling
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Decorative divider
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                SacredColors.borderGold.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const Text(
                          '© 2026 Bani Sagar • All rights reserved',
                          style: TextStyle(
                            color: SacredColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(DrawerItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onItemSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SacredColors.surfacePrimary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SacredColors.borderGold.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: SacredColors.primaryAccent,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 18),

                // Title with enhanced typography
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: SacredColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Subtle arrow indicator
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: SacredColors.primaryAccent.withValues(alpha: 0.3),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Pattern painter for drawer background
class DrawerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SacredColors.primaryAccent.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    const spacing = 50.0;
    const radius = 10.0;

    // Draw subtle circular pattern
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        // Alternate pattern for visual interest
        if ((x / spacing + y / spacing) % 3 == 0) {
          canvas.drawCircle(Offset(x, y), radius, paint);
        }
      }
    }

    // Add some flowing lines for elegance (very subtle)
    final linePaint = Paint()
      ..color = SacredColors.primaryAccent.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.3,
      size.width * 0.7, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.6,
      size.width, size.height * 0.4,
    );

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Alternative compact drawer for smaller screens
class CompactHomeDrawer extends StatelessWidget {
  const CompactHomeDrawer({super.key, required this.onItemSelected});

  final Function(DrawerItem) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: SacredColors.backgroundBlack,
      child: Container(
        decoration: const BoxDecoration(
          color: SacredColors.backgroundBlack,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Compact header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [SacredColors.primaryAccent, SacredColors.accentSoft],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: SacredColors.surfacePrimary,
                        child: CircleAvatar(
                          radius: 19,
                          backgroundImage: AssetImage('assets/images/khanda_image.png'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bani Sagar',
                            style: TextStyle(
                              color: SacredColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Spiritual Reader',
                            style: TextStyle(
                              color: SacredColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: SacredColors.borderGold.withValues(alpha: 0.1),
              ),

              // Compact menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  children: drawerItems.map((item) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SacredColors.surfacePrimary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: SacredColors.borderGold.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: SacredColors.primaryAccent,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: SacredColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => onItemSelected(item),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}