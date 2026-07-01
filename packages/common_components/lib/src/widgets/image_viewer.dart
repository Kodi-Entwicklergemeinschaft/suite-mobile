import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';
import 'app_image.dart';
import 'common_text.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageViewer extends ConsumerStatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<ImageViewer> createState() => _ImageViewerState();

  static void show(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => ImageViewer(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Image viewer
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Center(
                            child: CommonImage(
                              imagePath: widget.images[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Indicators and counter (only show if more than 1 image)
                if (widget.images.length > 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.images.length,
                            (index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Container(
                                width: _currentIndex == index ? 12.w : 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == index
                                      ? theme.colorScheme.primary
                                      : Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CommonText(
                          titleText: '${_currentIndex + 1}/${widget.images.length}',
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // Close button (overlaid on top)
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.chevron_left,
                  color: ref.watch(appThemeProvider).colors.surfaceLight,
                  size: 28.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
