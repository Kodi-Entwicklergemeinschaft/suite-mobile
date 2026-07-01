import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/core/widgets/date_badge.dart';
import 'package:template_c/core/widgets/favorite_button.dart';

/// Shared swipeable image carousel used by both [ListingItemCard] and
/// [DetailHeroSection]. Height and border-radius are configurable so each
/// context can keep its own Figma dimensions.
class ListingImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String? categoryFallbackImage;
  final String day;
  final String month;
  final bool isFavorite;
  final double height;
  final double borderRadius;
  final double badgeBorderRadius;
  final VoidCallback? onFavoriteTap;
  final bool showDateBadge;
  final bool showFavoriteButton;

  const ListingImageCarousel({
    super.key,
    required this.imageUrls,
    this.categoryFallbackImage,
    required this.day,
    required this.month,
    this.isFavorite = false,
    required this.height,
    this.borderRadius = 8,
    this.badgeBorderRadius = 4,
    this.onFavoriteTap,
    this.showDateBadge = true,
    this.showFavoriteButton = true,
  });

  @override
  State<ListingImageCarousel> createState() => _ListingImageCarouselState();
}

class _ListingImageCarouselState extends State<ListingImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.imageUrls.isEmpty ? 1 : widget.imageUrls.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color!,
          width: 1.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        child: SizedBox(
          height: widget.height.h,
          child: Stack(
            children: [
              // Images
              Positioned.fill(
                child: widget.imageUrls.isEmpty
                    ? Container(color: const Color(0xFF1B262D))
                    : PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        itemCount: imageCount,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (_, i) => CommonImage(
                          imagePath: widget.imageUrls[i],
                          fit: BoxFit.cover,
                          errorWidget:
                              (i == 0 &&
                                  widget.categoryFallbackImage?.isNotEmpty ==
                                      true &&
                                  widget.imageUrls[0] !=
                                      widget.categoryFallbackImage)
                              ? (context, error, stack) => CommonImage(
                                  imagePath: widget.categoryFallbackImage!,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.28, 1.0],
                        colors: [Color(0x000B0F13), Color(0xFF0B0F13)],
                      ),
                    ),
                  ),
                ),
              ),

              // Date badge (top-left)
              if (widget.showDateBadge)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: IgnorePointer(
                    child: DateBadge(
                      date: widget.day,
                      month: widget.month,
                      borderRadius: widget.badgeBorderRadius,
                    ),
                  ),
                ),

              // Bookmark button (top-right)
              if (widget.showFavoriteButton)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: FavoriteButton(
                    isFavorite: widget.isFavorite,
                    onTap: widget.onFavoriteTap,
                  ),
                ),

              // Carousel dots (bottom-center)
              if (imageCount > 1)
                Positioned(
                  bottom: 11.h,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(imageCount, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          width: isActive ? 12.w : 4.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF798CA3),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
