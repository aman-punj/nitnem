import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class BaniListTile extends StatefulWidget {
  final IconData icon;
  final String gurmukhiTitle;
  final String englishTitle;
  final VoidCallback onTap;
  final bool isCompleted;
  final Duration? estimatedTime;
  final bool showEstimatedTime;

  const BaniListTile({
    super.key,
    this.icon = Icons.auto_stories_outlined,
    required this.gurmukhiTitle,
    required this.englishTitle,
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: SacredColors.surfacePrimary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isCompleted
                      ? SacredColors.primaryAccent.withValues(alpha: 0.4)
                      : SacredColors.borderGold.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Leading Icon with sacred styling
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SacredColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: SacredColors.borderGold.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: SacredColors.primaryAccent,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Title and subtitle section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.gurmukhiTitle,
                          style: const TextStyle(
                            color: SacredColors.primaryAccent,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.englishTitle,
                          style: TextStyle(
                            color: SacredColors.textSecondary,
                            fontSize: 13,
                            height: 1.15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.showEstimatedTime &&
                            widget.estimatedTime != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: SacredColors.primaryAccent
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(widget.estimatedTime!),
                                style: TextStyle(
                                  color: SacredColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Trailing elements
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Completion status or Arrow
                      if (widget.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: SacredColors.primaryAccent
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: SacredColors.primaryAccent
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: SacredColors.primaryAccent,
                            size: 14,
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: SacredColors.primaryAccent
                              .withValues(alpha: 0.25),
                          size: 14,
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
