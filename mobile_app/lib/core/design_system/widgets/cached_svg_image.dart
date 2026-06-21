import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Network SVG with persistent disk caching via [flutter_cache_manager].
///
/// First load: downloads and stores the file locally.
/// Subsequent loads (including offline): reads from disk, no network request.
///
/// Drop-in replacement for [SvgPicture.network] wherever offline support matters.
class CachedSvgImage extends StatefulWidget {
  final String url;
  final ColorFilter? colorFilter;
  final WidgetBuilder? placeholderBuilder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CachedSvgImage({
    super.key,
    required this.url,
    this.colorFilter,
    this.placeholderBuilder,
    this.errorWidget,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  State<CachedSvgImage> createState() => _CachedSvgImageState();
}

class _CachedSvgImageState extends State<CachedSvgImage> {
  late final Future<File> _fileFuture;

  @override
  void initState() {
    super.initState();
    // getSingleFile: returns cached file immediately if present, otherwise
    // downloads, persists to disk, then returns — works offline after first load.
    _fileFuture = DefaultCacheManager().getSingleFile(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _fileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholderBuilder?.call(context) ??
              const SizedBox.shrink();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return widget.errorWidget ??
              widget.placeholderBuilder?.call(context) ??
              const SizedBox.shrink();
        }
        return SvgPicture.file(
          snapshot.data!,
          colorFilter: widget.colorFilter,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }
}
