import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

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
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    return '${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              padding: const EdgeInsets.symmetric(
                horizontal: SacredSpacing.gutter,
                vertical: SacredSpacing.gutter,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: SacredSpacing.gutter,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: c.surfacePrimary,
                borderRadius: BorderRadius.circular(SacredRadius.def),
                border: Border.all(
                  color: widget.isCompleted
                      ? c.primaryAccent.withValues(alpha: 0.4)
                      : c.borderGold.withValues(alpha: isDark ? 0.1 : 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: isDark ? 8 : 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Leading Icon
                  Container(
                    padding: const EdgeInsets.all(SacredSpacing.base),
                    decoration: BoxDecoration(
                      color: c.surfaceSecondary,
                      borderRadius: BorderRadius.circular(SacredRadius.def),
                      border: Border.all(
                        color: c.borderGold.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: c.primaryAccent,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: SacredSpacing.sm),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.gurmukhiTitle,
                          style: SacredTypography.bodyMd.copyWith(
                            color: c.primaryAccent,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: SacredSpacing.xs),
                        Text(
                          widget.englishTitle,
                          style: SacredTypography.meta.copyWith(
                            color: c.textSecondary,
                            height: 1.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.showEstimatedTime &&
                            widget.estimatedTime != null) ...[
                          const SizedBox(height: SacredSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: c.primaryAccent.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: SacredSpacing.xs),
                              Text(
                                _formatDuration(widget.estimatedTime!),
                                style: SacredTypography.meta.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: SacredSpacing.sm),

                  // Trailing
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(SacredSpacing.xs),
                          decoration: BoxDecoration(
                            color: c.primaryAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(SacredRadius.md),
                            border: Border.all(
                              color: c.primaryAccent.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: c.primaryAccent,
                            size: 14,
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: c.primaryAccent.withValues(alpha: 0.25),
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
