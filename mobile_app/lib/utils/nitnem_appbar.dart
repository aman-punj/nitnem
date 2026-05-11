import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design_system/tokens/colors.dart';

// Enhanced Sacred AppBar to replace the basic grey one
class NitnemAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? gurmukhiTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showPattern;
  final VoidCallback? onBackPressed;

  const NitnemAppBar({
    super.key,
    required this.title,
    this.gurmukhiTitle,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showPattern = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SacredColors.backgroundBlack.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: SacredColors.borderGold.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay (highly restrained)
          if (showPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: AppBarPatternPainter(),
              ),
            ),
          
          // Main AppBar content
          AppBar(
            title: gurmukhiTitle != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gurmukhiTitle!,
                        style: const TextStyle(
                          color: SacredColors.primaryAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          color: SacredColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: const TextStyle(
                      color: SacredColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
            centerTitle: centerTitle,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: leading ??
                (Navigator.canPop(context)
                    ? Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SacredColors.surfacePrimary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: SacredColors.borderGold.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                          color: SacredColors.primaryAccent,
                          onPressed: onBackPressed ?? () => Navigator.pop(context),
                          iconSize: 20,
                        ),
                      )
                    : null),
            actions: actions?.map((action) {
              if (action is IconButton) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: SacredColors.surfacePrimary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: SacredColors.borderGold.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: action.icon,
                    color: SacredColors.primaryAccent,
                    onPressed: action.onPressed,
                    iconSize: 20,
                  ),
                );
              }
              return action;
            }).toList(),
            iconTheme: const IconThemeData(
              color: SacredColors.primaryAccent,
            ),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (gurmukhiTitle != null ? 10 : 0),
      );
}

// Subtle pattern painter for AppBar background
class AppBarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SacredColors.primaryAccent.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    const dotSize = 1.2;
    const spacing = 30.0;

    // Draw subtle dot pattern
    for (double y = dotSize; y < size.height; y += spacing) {
      for (double x = dotSize; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Simple usage replacement for your current AppBar
class SimpleNitnemAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const SimpleNitnemAppBar({
    super.key,
    required this.title,
    this.actions,
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
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
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

// Usage Examples:

// 1. Direct replacement for your current AppBar:
/*
appBar: SimpleNitnemAppBar(
  title: 'Nitnem',
  centerTitle: true,
),
*/

// 2. Enhanced version with more features:
/*
appBar: NitnemAppBar(
  title: 'Nitnem', 
  gurmukhiTitle: 'ਨਿਤਨੇਮ', // Optional Gurmukhi
  centerTitle: true,
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
),
*/

// 3. For individual Bani pages:
/*
appBar: NitnemAppBar(
  title: 'Japji Sahib',
  gurmukhiTitle: 'ਜਪੁਜੀ ਸਾਹਿਬ',
  actions: [
    IconButton(
      icon: Icon(Icons.bookmark_border),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.share),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.text_fields),
      onPressed: () {},
    ),
  ],
),
*/