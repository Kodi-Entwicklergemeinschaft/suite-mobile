import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/home/data/models/tile_item.dart';


class TileSliderCarousel extends BaseStatefulWidget {
  final List<TileItem> items;
  final String? label;

  const TileSliderCarousel({super.key, required this.items, this.label});

  @override
  ConsumerState<TileSliderCarousel> createState() => _TileSliderCarouselState();
}

class _TileSliderCarouselState extends BaseStatefulWidgetState<TileSliderCarousel> {
  final PageController _controller = PageController(viewportFraction: 1);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage) setState(() => _currentPage = page);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(BuildContext context, TileItem item) {
    if (item.action == null) return;
    ref.read(templateAHandlerProvider).executeAction(
      context,
      item.action!,
      title: item.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: CommonText(
              titleText: widget.label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Stack(
        children: [
          SizedBox(
            height: 400.h,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                Color tagBgColor = theme.colorScheme.secondary;
                final hex = item.titleBackgroundColor;
                if (hex != null && hex.isNotEmpty) {
                  try { tagBgColor = Color(int.parse(hex.replaceFirst('#', '0xff'))); } catch (_) {}
                }
                return _TileSliderCard(
                  item: item,
                  tagBgColor: tagBgColor,
                  onTap: () => _onItemTap(context, item),
                );
              },
            ),
          ),
          if (widget.items.length > 1)
            Positioned(
              top: 10.h,
              left: 0,
              right: 0,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.items.length, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 8.h,
                      width: 8.w,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
        ),
      ],
    );
  }
}

class _TileSliderCard extends StatelessWidget {
  final TileItem item;
  final Color tagBgColor;
  final VoidCallback? onTap;

  const _TileSliderCard({
    required this.item,
    required this.tagBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Semantics(
      button: onTap != null,
      label: [item.label, item.description].whereType<String>().where((s) => s.isNotEmpty).join(', '),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            width: screenWidth,
            child: Stack(
              children: [
                Positioned.fill(
                  child: (item.image != null && item.image!.isNotEmpty)
                      ? CommonImage(
                          imagePath: item.image!,
                          fit: BoxFit.cover,
                          label: item.label ?? '',
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                tagBgColor.withValues(alpha: 0.6),
                                tagBgColor,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: 40.sp,
                              color: Colors.white30,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.h, bottom: 24.h, right: 40.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.label != null && item.label!.isNotEmpty)
                        Container(
                          constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: tagBgColor,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.icon != null && item.icon!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: CommonImage(
                                    imagePath: item.icon!,
                                    height: 22.h,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Padding(
                                  padding: EdgeInsets.only(right: 6.w),
                                  child: Icon(
                                    Icons.card_giftcard,
                                    size: 20.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: CommonText(
                                  titleText: item.label!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      if (item.subtitle != null && item.subtitle!.isNotEmpty ||
                          item.description != null && item.description!.isNotEmpty)
                        Container(
                          constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8.r),
                              bottomRight: Radius.circular(8.r),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.subtitle != null && item.subtitle!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 4, right: 4, top: 2),
                                  child: Text(
                                    item.subtitle!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              if (item.description != null && item.description!.isNotEmpty)
                                Html(
                                  data: item.description,
                                  style: {
                                    'body': Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.only(
                                        left: 4,
                                        right: 4,
                                        top: 1,
                                        bottom: 6,
                                      ),
                                      fontSize: FontSize(9),
                                      color: Colors.white,
                                      maxLines: 5,
                                      textOverflow: TextOverflow.ellipsis,
                                    ),
                                    'span': Style(color: Colors.white),
                                    'p': Style(margin: Margins.zero),
                                    'div': Style(margin: Margins.zero),
                                    'a': Style(textDecoration: TextDecoration.none, color: Colors.white),
                                  },
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
