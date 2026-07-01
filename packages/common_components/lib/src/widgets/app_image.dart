import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'common_icon.dart';
import 'common_shimmer.dart';

/// A common image widget that can display network images, asset images,
/// and SVG images (both from network and assets).
///
/// It intelligently decides which widget to use based on the image path.
class CommonImage extends StatelessWidget {
  /// The path to the image. Can be a network URL or a local asset path.
  final String imagePath;

  /// The height of the image.
  final double? height;

  /// The width of the image.
  final double? width;

  /// How the image should be inscribed into the box.
  final BoxFit fit;

  final Color? color;

  final String? label;
  final File? imageFile;
  final int? cacheHeight;
  final int? cacheWidth;

  /// A builder function that is called if an error occurs during image loading.
  final Widget Function(BuildContext, Object, StackTrace?)? errorWidget;

  /// Optional widget shown while a network image is loading. If null, shimmer is used.
  final Widget? loadingWidget;

  const CommonImage(
      {super.key,
      required this.imagePath,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.errorWidget,
      this.color,
      this.label = "Image",
      this.cacheHeight,
      this.cacheWidth,
      this.imageFile,
      this.loadingWidget});

  bool get _isFileImage => imageFile != null;

  bool get _isSvg => imagePath.toLowerCase().endsWith('.svg');
  bool get _isNetworkImage =>
      imagePath.toLowerCase().startsWith('http://') ||
      imagePath.toLowerCase().startsWith('https://');

  Widget _buildShimmerPlaceholder() {
    return CommonShimmer(
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }

  Widget _defaultErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    final placeholderPath = Theme.of(context).brightness == Brightness.light
        ? "assets/svg/placeholder_light.svg"
        : "assets/svg/placeholder_dark.svg";

    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        placeholderPath,
        fit: fit,
        semanticsLabel: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return CommonImage(
        cacheWidth: 400,
        cacheHeight: 400,
        width: width,
        height: height,
        fit: fit,
        imagePath: Theme.of(context).brightness == Brightness.light
            ? "assets/svg/placeholder_light.svg"
            : "assets/svg/placeholder_dark.svg",
      );
    }

    // Handle File Image
    if (_isFileImage) {
      return Semantics(
        label: label,
        child: Image.file(
          imageFile!,
          height: height,
          width: width,
          fit: fit,
          gaplessPlayback: true,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          color: color,
          errorBuilder: errorWidget ?? _defaultErrorWidget,
          semanticLabel: label,
        ),
      );
    }

    if (_isSvg) {
      if (_isNetworkImage) {
        return _CachedNetworkSvg(
          url: imagePath,
          height: height,
          width: width,
          fit: fit,
          color: color,
          label: label,
          placeholder: _buildShimmerPlaceholder(),
          errorBuilder: _defaultErrorWidget,
        );
      } else {
        return SvgPicture.asset(
          imagePath,
          height: height,
          width: width,
          fit: fit,
          colorFilter:
              color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          semanticsLabel: label,
        );
      }
    } else if (_isNetworkImage) {
      return Semantics(
        label: label,
        child: CachedNetworkImage(
          imageUrl: imagePath,
          height: height,
          width: width,
          fit: fit,
          memCacheHeight: cacheHeight,
          memCacheWidth: cacheWidth,
          progressIndicatorBuilder: (context, child, loadingProgress) {
            if (loadingWidget != null) return loadingWidget!;
            return _buildShimmerPlaceholder();
          },
          errorWidget: (context, url, error) {
            // Use custom error widget if provided, otherwise use default
            return errorWidget?.call(context, error, null) ??
                _defaultErrorWidget(context, error, null);
          },
        ),
      );
    } else {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        color: color,
        errorBuilder: errorWidget ?? _defaultErrorWidget,
        semanticLabel: label,
      );
    }
  }
}

// Alias for consistency with kiel.app
typedef AppImage = CommonImage;

/// Loads a remote SVG via [DefaultCacheManager] so bytes are persisted to the
/// same on-disk cache used by [CachedNetworkImage]. This makes SVGs available
/// offline after the first successful online fetch.
///
/// The future is created in [initState] so widget rebuilds don't re-trigger
/// the cache lookup on every frame.
class _CachedNetworkSvg extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Color? color;
  final String? label;
  final Widget placeholder;
  final Widget Function(BuildContext, Object, StackTrace?) errorBuilder;

  const _CachedNetworkSvg({
    required this.url,
    required this.fit,
    required this.placeholder,
    required this.errorBuilder,
    this.height,
    this.width,
    this.color,
    this.label,
  });

  @override
  State<_CachedNetworkSvg> createState() => _CachedNetworkSvgState();
}

class _CachedNetworkSvgState extends State<_CachedNetworkSvg> {
  late Future<File> _future;

  @override
  void initState() {
    super.initState();
    debugPrint('[CachedNetworkSvg] initState fetch → ${widget.url}');
    _future = DefaultCacheManager().getSingleFile(widget.url);
  }

  @override
  void didUpdateWidget(covariant _CachedNetworkSvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      debugPrint(
          '[CachedNetworkSvg] didUpdateWidget fetch (URL changed) → ${widget.url}');
      _future = DefaultCacheManager().getSingleFile(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.placeholder;
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return widget.errorBuilder(
            context,
            snapshot.error ?? Exception('svg cache miss'),
            null,
          );
        }
        return SvgPicture.file(
          snapshot.data!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          colorFilter: widget.color != null
              ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
              : null,
          semanticsLabel: widget.label,
        );
      },
    );
  }
}
