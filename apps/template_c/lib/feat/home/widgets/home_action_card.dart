import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:template_c/feat/handler/template_c_handler.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/data/models/home_config.dart';
import 'package:template_c/feat/home/widgets/listing/listing_card_shells.dart';

/// Single or multi-item tappable card(s) for home components with a
/// non-category action (url_webview, url_browser, feature, service_hub).
/// - If config.items is non-empty → horizontal scroll list, one card per item.
/// - Otherwise → single card from config-level image/title/subtitle.
/// Reuses StandardCardShell (V2) or CompactCardShell (V3) to match listing UI.
class HomeActionCard extends ConsumerWidget {
  final ContentSliderConfig config;

  const HomeActionCard({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasItems = config.items != null && config.items!.isNotEmpty;
    final isCompact = config.variant == HomeScreenConstant.contentSliderV3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.label != null && config.label!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CommonText(
              titleText: config.label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
        if (hasItems)
          _ItemsList(items: config.items!, isCompact: isCompact, ref: ref)
        else
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            child: _buildCard(
              context: context,
              ref: ref,
              image: config.image,
              title: config.title ?? config.label,
              subtitle: config.subtitle,
              isCompact: isCompact,
              onTap: config.action != null
                  ? () => ref
                        .read(templateCHandlerProvider)
                        .executeAction(
                          context,
                          config.action!,
                          title: config.title ?? config.label,
                        )
                  : null,
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// HORIZONTAL ITEMS LIST
// ============================================================================

class _ItemsList extends StatelessWidget {
  final List<HomeActionItem> items;
  final bool isCompact;
  final WidgetRef ref;

  const _ItemsList({
    required this.items,
    required this.isCompact,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isCompact ? 304.w : 296.w;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              SizedBox(
                width: cardWidth,
                child: _buildCard(
                  context: context,
                  ref: ref,
                  image: items[i].image,
                  title: items[i].title ?? items[i].label,
                  subtitle: items[i].subtitle,
                  isCompact: isCompact,
                  onTap: items[i].action != null
                      ? () => ref
                            .read(templateCHandlerProvider)
                            .executeAction(
                              context,
                              items[i].action!,
                              title: items[i].title ?? items[i].label,
                            )
                      : null,
                ),
              ),
              if (i < items.length - 1) SizedBox(width: 12.w),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CARD BUILDER — shared by single and list paths
// ============================================================================

Widget _buildCard({
  required BuildContext context,
  required WidgetRef ref,
  required String? image,
  required String? title,
  required String? subtitle,
  required bool isCompact,
  required VoidCallback? onTap,
}) {
  final theme = Theme.of(context);

  final imageWidget = CommonImage(
    imagePath: image ?? '',
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
  );

  if (isCompact) {
    return CompactCardShell(
      onTap: onTap,
      imageWidget: imageWidget,
      contentColumn: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title.isNotEmpty) ...[
            CardTitleText(title),
            SizedBox(height: 4.h),
          ],
          if (subtitle != null && subtitle.isNotEmpty)
            CardSubtitleText(subtitle),
        ],
      ),
    );
  }

  return StandardCardShell(
    onTap: onTap,
    imageWidget: ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(height: 272.h, child: imageWidget),
    ),
    infoSection: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null && title.isNotEmpty) ...[
            CardTitleText(title, maxLines: 2),
            SizedBox(height: 6.h),
          ],
          if (subtitle != null && subtitle.isNotEmpty)
            CardSubtitleText(subtitle),
        ],
      ),
    ),
  );
}
