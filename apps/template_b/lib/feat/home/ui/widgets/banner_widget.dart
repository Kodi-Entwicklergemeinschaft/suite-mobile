import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/feat/home/data/models/home_config.dart';

class BannerWidget extends StatefulWidget {
  /// All visible banner configs, displayed as a swipeable carousel.
  final List<BannerConfig> banners;

  /// Called when a banner is tapped, receiving the tapped [BannerConfig].
  final void Function(BannerConfig banner)? onTap;

  const BannerWidget({super.key, required this.banners, this.onTap});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  late final PageController _pageController;
  int _currentPage = 0;

  /// Measured heights keyed by banner index; updated after each card lays out.
  final Map<int, double> _cardHeights = {};

  bool get _isMultiple => widget.banners.length > 1;

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

  BannerConfig get _current => widget.banners[_currentPage];

  /// Height to give the PageView — uses the current page's measured height,
  /// falling back to a safe maximum until the first measurement arrives.
  double get _pageViewHeight {
    return _cardHeights[_currentPage] ?? _safeMaxHeight;
  }

  /// Upper bound before any measurement: image (160.h) + 4 lines text + padding.
  double get _safeMaxHeight => 160.h + (11.sp * 1.4 * 4) + 16.h + 16.h;

  void _onCardHeightMeasured(int index, double height) {
    if (_cardHeights[index] == height) return;
    setState(() => _cardHeights[index] = height);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label updates dynamically as the current page changes
        if (_current.label != null)
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
            child: CommonText(
              titleText: _current.label!,
              isHeader: true,
              overflow: TextOverflow.visible,
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

        // PageView spans full width — padding lives inside each page so the
        // viewport boundary exactly matches the card edge.
        // AnimatedSize smoothly resizes the PageView as the user swipes between
        // banners that have different amounts of description text.
        _isMultiple
            ? AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: _pageViewHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.banners.length,
                    pageSnapping: true,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _MeasuredBannerCard(
                        banner: widget.banners[index],
                        onTap: widget.onTap,
                        onHeightMeasured: (h) =>
                            _onCardHeightMeasured(index, h),
                      ),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _MeasuredBannerCard(
                  banner: widget.banners.first,
                  onTap: widget.onTap,
                ),
              ),

        // Dot indicators — only rendered when there are multiple banners
        if (_isMultiple) ...[SizedBox(height: 10.h), _buildDotIndicators()],
      ],
    );
  }

  /// Animated pill dots — active dot stretches, inactive dots shrink.
  /// Purely decorative, so excluded from the semantics tree.
  Widget _buildDotIndicators() {
    return ExcludeSemantics(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.banners.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isActive ? 20.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// A single banner card that measures its own rendered height and reports it
/// to the parent via [onHeightMeasured]. This lets the parent [PageView] size
/// itself exactly to the tallest visible card without a hard-coded constant.
class _MeasuredBannerCard extends StatefulWidget {
  final BannerConfig banner;
  final void Function(BannerConfig)? onTap;

  /// Called once (and again if the height changes) with the card's pixel height.
  /// Null for the single-banner case where no external sizing is needed.
  final void Function(double height)? onHeightMeasured;

  const _MeasuredBannerCard({
    required this.banner,
    this.onTap,
    this.onHeightMeasured,
  });

  @override
  State<_MeasuredBannerCard> createState() => _MeasuredBannerCardState();
}

class _MeasuredBannerCardState extends State<_MeasuredBannerCard> {
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.onHeightMeasured != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportHeight());
    }
  }

  void _reportHeight() {
    final ctx = _cardKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    widget.onHeightMeasured?.call(box.size.height);
  }

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      key: _cardKey,
      borderRadius: BorderRadius.circular(8.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonImage(
            imagePath: widget.banner.image!,
            height: 160.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          if (widget.banner.description != null)
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: CommonText(
                titleText: widget.banner.description!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textStyle: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );

    final semanticLabel = [
      widget.banner.label,
      widget.banner.description,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return Semantics(
      button: widget.onTap != null,
      label: semanticLabel.isNotEmpty
          ? semanticLabel
          : 'home_header_banner_label'.tr,
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.banner),
        child: ExcludeSemantics(
          child: widget.onHeightMeasured != null
              ? OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: card,
                )
              : card,
        ),
      ),
    );
  }
}
