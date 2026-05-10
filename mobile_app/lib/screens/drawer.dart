import 'package:flutter/material.dart';

import '../models/drawer_item.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.onItemSelected});

  final Function(DrawerItem) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFDF7), // Warm cream
              Color(0xFFF5E6B8), // Light golden
              Color(0xFFE8D5A3), // Deeper gold
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle background pattern
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD4AF37),
                                Color(0xFFB8860B),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4C19C).withValues(alpha:0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 32,
                            backgroundColor: Color(0xFFFFFDF7),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage('assets/images/khanda_image.png'),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // App Title with Gurmukhi
                        // const Text(
                        //   'ਬਾਣੀ', // Bani in Gurmukhi
                        //   style: TextStyle(
                        //     color: Color(0xFF8B4513),
                        //     fontSize: 28,
                        //     fontWeight: FontWeight.bold,
                        //     height: 1.2,
                        //   ),
                        // ),

                        const SizedBox(height: 4),

                        Text(
                          'Bani Sagar',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF8B4513),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // const SizedBox(height: 6),
                        //
                        // const Text(
                        //   'Spiritual Bani Reader',
                        //   style: TextStyle(
                        //     color: Color(0xFF8B4513),
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w500,
                        //     letterSpacing: 0.5,
                        //   ),
                        // ),

                        const SizedBox(height: 16),

                        // Decorative divider
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD4AF37),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: drawerItems.map((item) => _buildDrawerItem(item)).toList(),
                    ),
                  ),

                  // Footer with enhanced styling
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Decorative divider
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFE6D3A3).withValues(alpha:0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const Text(
                          '© 2025 nBani • All rights reserved',
                          style: TextStyle(
                            color: Color(0xFF8B4513),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
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
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onItemSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37).withValues(alpha:0.15),
                        const Color(0xFFB8860B).withValues(alpha:0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: const Color(0xFF8B4513),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Title with enhanced typography
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Color(0xFF8B4513),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Subtle arrow indicator
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFF8B4513).withValues(alpha: 0.4),
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
      ..color = const Color(0xFFD4AF37).withValues(alpha:0.05)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const radius = 15.0;

    // Draw subtle circular pattern
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        // Alternate pattern for visual interest
        if ((x / spacing + y / spacing) % 2 == 0) {
          canvas.drawCircle(Offset(x, y), radius, paint);
        }
      }
    }

    // Add some flowing lines for elegance
    final linePaint = Paint()
      ..color = const Color(0xFFE6D3A3).withValues(alpha:0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.2,
      size.width * 0.6, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.5,
      size.width, size.height * 0.3,
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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFDF7),
              Color(0xFFF5E6B8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Compact header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFFFFDF7),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage('assets/images/khanda_image.png'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ਬਾਣੀ',
                            style: TextStyle(
                              color: Color(0xFF8B4513),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Spiritual Reader',
                            style: TextStyle(
                              color: Color(0xFF8B4513),
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
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: const Color(0xFFE6D3A3).withValues(alpha:0.5),
              ),

              // Compact menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: drawerItems.map((item) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFF8B4513),
                        size: 18,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF8B4513),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => onItemSelected(item),
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ),

              // Compact footer
              // const Padding(
              //   padding: EdgeInsets.all(16),
              //   child: Text(
              //     '© 2025 nBani',
              //     style: TextStyle(
              //       color: Color(0xFF8B4513),
              //       fontSize: 10,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}