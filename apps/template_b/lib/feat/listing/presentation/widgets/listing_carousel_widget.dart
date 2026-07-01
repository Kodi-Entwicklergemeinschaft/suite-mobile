import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import '../../data/models/listing_media_model.dart';

/// Image carousel widget for listing detail screen using Material 3 CarouselView
class ListingCarouselWidget extends StatefulWidget {
  final String? heroImageUrl;
  final String? categoryFallbackImage;
  final List<ListingMediaModel>? media;
  final VoidCallback? onImageTap;

  const ListingCarouselWidget({
    Key? key,
    this.heroImageUrl,
    this.categoryFallbackImage,
    this.media,
    this.onImageTap,
  }) : super(key: key);

  @override
  State<ListingCarouselWidget> createState() => _ListingCarouselWidgetState();
}

class _ListingCarouselWidgetState extends State<ListingCarouselWidget> {
  late CarouselController _carouselController;
  late List<String> _imageList;
  int _currentIndex = 0;

  void _openImageViewer() {
    ImageViewer.show(context, images: _imageList, initialIndex: _currentIndex);
  }

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselController();
    _imageList = _getImageList();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _onScrollNotification(ScrollNotification notification, int itemCount) {
    if (notification is ScrollUpdateNotification && itemCount > 0) {
      final metrics = notification.metrics;
      final itemWidth = metrics.viewportDimension;

      // Calculate current page based on scroll offset
      final currentPage = (metrics.pixels / itemWidth).round();

      if (currentPage != _currentIndex &&
          currentPage >= 0 &&
          currentPage < itemCount) {
        setState(() {
          _currentIndex = currentPage;
        });
      }
    }
  }

  List<String> _getImageList() {
    final images = <String>[];
    final addedUrls = <String>{};

    // Add hero image first, fall back to categoryFallbackImage
    final primaryImage = (widget.heroImageUrl?.isNotEmpty == true)
        ? widget.heroImageUrl!
        : (widget.categoryFallbackImage?.isNotEmpty == true)
        ? widget.categoryFallbackImage!
        : null;

    if (primaryImage != null) {
      images.add(primaryImage);
      addedUrls.add(primaryImage);
    }

    // Add media images (skip if already added as hero image)
    if (widget.media != null && widget.media!.isNotEmpty) {
      for (final mediaItem in widget.media!) {
        if (mediaItem.url != null &&
            mediaItem.url!.isNotEmpty &&
            !addedUrls.contains(mediaItem.url!)) {
          images.add(mediaItem.url!);
          addedUrls.add(mediaItem.url!);
        }
      }
    }

    return images;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no images, show placeholder
    if (_imageList.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250.h,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.colorScheme.onSurface,
          size: 48,
        ),
      );
    }

    // Always show carousel using Material 3 CarouselView with indicators on top
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: theme.dividerTheme.color!, width: 1.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                _onScrollNotification(notification, _imageList.length);
                return false;
              },
              child: CarouselView(
                onTap: (value) {
                  _openImageViewer();
                  widget.onImageTap?.call();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10.r),
                ),
                controller: _carouselController,
                itemExtent: double.infinity,
                itemSnapping: true,
                children: List.generate(
                  _imageList.length,
                  (index) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: CommonImage(
                      imagePath: _imageList[index],
                      fit: BoxFit.cover,
                      label: 'Listing image ${index + 1}',
                      errorWidget:
                          (index == 0 &&
                              widget.heroImageUrl?.isNotEmpty == true &&
                              widget.categoryFallbackImage?.isNotEmpty ==
                                  true &&
                              widget.heroImageUrl !=
                                  widget.categoryFallbackImage)
                          ? (context, error, stack) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && _imageList.isNotEmpty) {
                                  setState(() {
                                    _imageList[0] =
                                        widget.categoryFallbackImage!;
                                  });
                                }
                              });
                              return CommonImage(
                                imagePath: widget.categoryFallbackImage!,
                                fit: BoxFit.cover,
                                label: 'Listing image ${index + 1}',
                              );
                            }
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Carousel indicators positioned at bottom (only show if more than one image)
        if (_imageList.length > 1)
          Positioned(
            bottom: 12.h,
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _imageList.length,
                  (index) => Container(
                    height: 8.h,
                    width: _currentIndex == index ? 24.w : 8.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: _currentIndex == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
