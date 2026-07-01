import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'app_image.dart';

/// A custom SliverPersistentHeaderDelegate for animated search bar with background image.
///
/// This delegate handles scroll animations including:
/// - Background image blur and slide effect
/// - Search bar scaling animation
/// - Smooth transitions between expanded and collapsed states
class SliverSearchAppBarDelegate extends SliverPersistentHeaderDelegate {
  /// Minimum height when fully collapsed
  final double minHeight;

  /// Maximum height when fully expanded
  final double maxHeight;

  /// The search bar widget to display (typically SearchBarWidget)
  final Widget child;

  /// Optional background image URL
  final String? backgroundImage;

  /// Background color when image is not available or blurred
  final Color containerColor;

  /// Maximum blur sigma for background image
  final double maxBlurSigma;

  /// Maximum horizontal offset during collapse animation
  final double maxLeftOffset;

  /// Maximum scale reduction during collapse animation
  final double maxScaleReduction;

  /// Callback for menu button press
  final VoidCallback? onMenuPressed;

  SliverSearchAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    this.backgroundImage,
    this.containerColor = Colors.white,
    this.maxBlurSigma = 10.0,
    this.maxLeftOffset = 35,
    this.maxScaleReduction = 0.19,
    this.onMenuPressed,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate progress ratio (0.0 = fully expanded, 1.0 = fully collapsed)
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Check if hamburger menu is visible
    final isHamburgerVisible = onMenuPressed != null;

    // Calculate animation values based on progress
    // Only apply collapse animation when hamburger is visible
    final leftOffset = isHamburgerVisible ? progress * maxLeftOffset : 0.0;
    final imageSlideOffset = progress * 100; // Controls slide speed
    final blurAmount = progress * maxBlurSigma;
    final scaleAmount =
        isHamburgerVisible ? 1.0 - (progress * maxScaleReduction) : 1.0;

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: maxExtent,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Background - either image or primary color
            if (backgroundImage != null)
              // Background image with blur and slide animations
              PositionedDirectional(
                top: -imageSlideOffset, // Creates sliding up effect
                start: 0,
                end: 0,
                bottom: 0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Blurred image
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blurAmount,
                        sigmaY: blurAmount,
                      ),
                      child: CommonImage(
                        errorWidget: (c, obj, st) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        imagePath: backgroundImage!,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Black gradient overlay (top to center)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .scrim
                                  .withValues(alpha: 0.5),
                              Theme.of(context)
                                  .colorScheme
                                  .scrim
                                  .withValues(alpha: 0.1)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // Fallback to primary color gradient when no image
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),

            // Menu button - only visible when hamburger is enabled
            if (isHamburgerVisible)
              PositionedDirectional(
                start: 16,
                top: statusBarHeight + 16,
                child: GestureDetector(
                  onTap: onMenuPressed,
                  child: Icon(
                    Icons.menu,
                  ),
                ),
              ),

            // Search bar container with scaling animation
            // Only apply scale/offset animation when hamburger is visible
            PositionedDirectional(
              bottom: 0,
              start: leftOffset,
              end: 0,
              child: Transform.scale(
                scale: scaleAmount,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverSearchAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child ||
        backgroundImage != oldDelegate.backgroundImage ||
        containerColor != oldDelegate.containerColor ||
        maxBlurSigma != oldDelegate.maxBlurSigma ||
        maxLeftOffset != oldDelegate.maxLeftOffset ||
        maxScaleReduction != oldDelegate.maxScaleReduction ||
        onMenuPressed != oldDelegate.onMenuPressed;
  }
}
