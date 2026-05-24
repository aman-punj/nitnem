import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

class BaniListTile extends StatefulWidget {
  final IconData icon;
  final String? iconUrl;
  final String? iconAsset;
  final String gurmukhiTitle;
  final String englishTitle;
  final VoidCallback onTap;
  final bool isCompleted;
  final Duration? estimatedTime;
  final bool showEstimatedTime;

  const BaniListTile({
    super.key,
    this.icon = Icons.auto_stories_outlined,
    this.iconUrl,
    this.iconAsset,
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

  Widget _buildLeadingIcon(SacredColors c) {
    // Priority: network iconUrl > bundled SVG asset > fallback Material icon
    final url = widget.iconUrl;
    if (url != null && url.isNotEmpty) {
      if (url.toLowerCase().endsWith('.svg')) {
        // SVG from Cloudinary — tinted with theme accent, single file for both modes
        return Padding(
          padding: const EdgeInsets.all(11),
          child: SvgPicture.network(
            url,
            colorFilter: ColorFilter.mode(c.primaryAccent, BlendMode.srcIn),
            placeholderBuilder: (_) => _svgOrIcon(c),
          ),
        );
      }
      // Raster image (PNG/JPEG) — cached to disk, works offline after first load
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => _svgOrIcon(c),
        errorWidget: (_, __, ___) => _svgOrIcon(c),
      );
    }
    return _svgOrIcon(c);
  }

  Widget _svgOrIcon(SacredColors c) {
    if (widget.iconAsset != null) {
      return Padding(
        padding: const EdgeInsets.all(11),
        child: SvgPicture.asset(
          widget.iconAsset!,
          colorFilter: ColorFilter.mode(c.primaryAccent, BlendMode.srcIn),
        ),
      );
    }
    return Center(child: Icon(widget.icon, color: c.primaryAccent, size: 22));
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                    blurRadius: isDark ? 12 : 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Leading Icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: c.surfaceSecondary,
                      borderRadius: BorderRadius.circular(SacredRadius.def),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildLeadingIcon(c),
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
