import 'package:flutter/material.dart';

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
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFFDF7).withValues(alpha:0.9),
                    const Color(0xFFF5E6B8).withValues(alpha:0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isCompleted
                      ? const Color(0xFFD4AF37).withValues(alpha:0.5)
                      : const Color(0xFFE6D3A3).withValues(alpha:0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4C19C).withValues(alpha:0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha:0.8),
                    blurRadius: 8,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Leading Icon with sacred styling
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37).withValues(alpha:0.2),
                          const Color(0xFFB8860B).withValues(alpha:0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha:0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: const Color(0xFF8B4513),
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
                            color: Color(0xFF8B4513),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: const Color(0xFF8B4513).withValues(alpha:0.7),
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                        ],
                        if (widget.showEstimatedTime && widget.estimatedTime != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: const Color(0xFF8B4513).withValues(alpha:0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(widget.estimatedTime!),
                                style: TextStyle(
                                  color: const Color(0xFF8B4513).withValues(alpha:0.6),
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
                            color: const Color(0xFFD4AF37).withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withValues(alpha:0.4),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFB8860B),
                            size: 16,
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Arrow indicator
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: const Color(0xFF8B4513).withValues(alpha:0.5),
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

// Alternative compact version for dense lists
class CompactBaniListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isCompleted;

  const CompactBaniListTile({
    super.key,
    this.icon = Icons.auto_stories_outlined,
    required this.title,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  State<CompactBaniListTile> createState() => _CompactBaniListTileState();
}

class _CompactBaniListTileState extends State<CompactBaniListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFFDF7).withValues(alpha:0.8),
              const Color(0xFFF5E6B8).withValues(alpha:0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE6D3A3).withValues(alpha:0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4C19C).withValues(alpha:0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: const Color(0xFF8B4513),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFF8B4513),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.isCompleted)
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFFD4AF37),
                size: 18,
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF8B4513).withValues(alpha:0.4),
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

// Specialized tile for different Bani types
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
    final accent = accentColor ?? const Color(0xFFD4AF37);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha:0.95),
              accent.withValues(alpha:0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accent.withValues(alpha:0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha:0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    color: accent.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accent.withValues(alpha:0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF8B4513),
                    size: 28,
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha:0.2),
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
            const SizedBox(height: 16),
            if (gurmukhiTitle != null) ...[
              Text(
                gurmukhiTitle!,
                style: const TextStyle(
                  color: Color(0xFF8B4513),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF8B4513).withValues(alpha:0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage examples and constants
class BaniIcons {
  static const IconData japjiSahib = Icons.wb_sunny_outlined;
  static const IconData jaapSahib = Icons.auto_stories_outlined;
  static const IconData tvaPresaad = Icons.spa_outlined;
  static const IconData chaupaiSahib = Icons.shield_outlined;
  static const IconData anandSahib = Icons.favorite_border_outlined;
  static const IconData rehrasSahib = Icons.wb_twilight_outlined;
  static const IconData kirtan = Icons.music_note_outlined;
  static const IconData ardaas = Icons.pan_tool_outlined;
}