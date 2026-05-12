import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class BaniListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isCompleted;
  final Duration? estimatedTime;
  final bool showEstimatedTime;

  const BaniListTile({
    super.key,
    this.icon = Icons.auto_stories_outlined,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isCompleted = false,
    this.estimatedTime,
    this.showEstimatedTime = false,
  });

  @override
  State<BaniListTile> createState() => _BaniListTileState();
}

class _BaniListTileState extends State<BaniListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    return '${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: SacredColors.surfacePrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isCompleted
                      ? SacredColors.primaryAccent.withValues(alpha: 0.4)
                      : SacredColors.borderGold.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Leading Icon with sacred styling
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SacredColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SacredColors.borderGold.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: SacredColors.primaryAccent,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Title and subtitle section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: SacredColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: SacredColors.textSecondary,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                        ],
                        if (widget.showEstimatedTime && widget.estimatedTime != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: SacredColors.primaryAccent.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDuration(widget.estimatedTime!),
                                style: TextStyle(
                                  color: SacredColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing elements
                  Column(
                    children: [
                      // Completion status
                      if (widget.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: SacredColors.primaryAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: SacredColors.primaryAccent.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: SacredColors.primaryAccent,
                            size: 16,
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Arrow indicator
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: SacredColors.primaryAccent.withValues(alpha: 0.3),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpecialBaniTile extends StatelessWidget {
  final String title;
  final String? gurmukhiTitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isCompleted;
  final Color? accentColor;

  const SpecialBaniTile({
    super.key,
    required this.title,
    this.gurmukhiTitle,
    this.icon = Icons.auto_stories_outlined,
    required this.onTap,
    this.isCompleted = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? SacredColors.primaryAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: SacredColors.surfacePrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SacredColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 28,
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: accent,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (gurmukhiTitle != null) ...[
              Text(
                gurmukhiTitle!,
                style: const TextStyle(
                  color: SacredColors.primaryAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                color: SacredColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
