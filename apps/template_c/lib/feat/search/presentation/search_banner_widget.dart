import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/widgets/badge_icon_widget.dart';
import 'package:template_c/core/widgets/carousal_indicator.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:template_c/feat/search/filter/search_filter_controller.dart';
import 'package:template_c/feat/search/filter/search_filter_sheet.dart';
import 'package:template_c/feat/search/controller/search_controller.dart';

const _groupIcons = [
  'assets/svg/infrastructure.svg',
  'assets/svg/culture.svg',
  'assets/svg/infrastructure.svg',
];

class SearchBannerWidget extends BaseStatefulWidget {
  const SearchBannerWidget({super.key});

  @override
  ConsumerState<SearchBannerWidget> createState() => _SearchBannerWidgetState();
}

class _SearchBannerWidgetState extends BaseStatefulWidgetState<SearchBannerWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(searchFilterControllerProvider);

    if (filterState.stateConstant != StateConstant.success || filterState.groups.isEmpty) {
      return const SizedBox.shrink();
    }

    final groups = filterState.groups;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height:200.h,
          child: PageView.builder(
            clipBehavior: Clip.none,
            controller: _pageController,
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w, top: 20.h),
                child: _BannerCard(
                  group: groups[index],
                  iconAsset: groups[index].icon ?? '',
                  // iconAsset: _groupIcons[index % _groupIcons.length],
                  onTap: () => showSearchFilterSheet(
                    context,
                    focusGroupId: groups[index].id,
                    onDateRemoved: () async {
                      await ref.read(searchControllerProvider.notifier).updateDateFilter(null);
                    },
                    onFreeEntryRemoved: () {
                      ref.read(searchControllerProvider.notifier).toggleFreeEntry();
                    },
                    onLocationRemoved: () async {
                      await ref.read(searchControllerProvider.notifier).clearLocationFilter();
                    },
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        CarouselIndicatorWidget(
          itemCount: groups.length,
          controller: _pageController,
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.group, required this.iconAsset, required this.onTap});

  final InterestConfigCategories group;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chips = (group.children ?? []).map((c) => c.title ?? '').where((t) => t.isNotEmpty).toList();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 50.w),
                  child: Text(
                    group.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              
                _OverflowChipRow(chips: chips),
                SizedBox(height: 12.h),
                  Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'search_banner_action'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right, color: Colors.white, size: 18.sp),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12.w,
            top: -25.h,
            child: BadgeIconWidget(foregroundIconPath: iconAsset,width: 60.w,height: 60.h,)
          ),
        ],
      ),
    );
  }
}

class _OverflowChipRow extends StatelessWidget {
  const _OverflowChipRow({required this.chips});

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final spacing = 8.w;
    final chipStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
    final horizontalPadding = 10.w * 2;
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - 8.w;

        double usedWidth = 0;
        final visibleChips = <String>[];
        bool overflow = false;

        final ellipsisChipWidth =
            _textWidth('...', chipStyle, textScaler) + horizontalPadding;

        for (int i = 0; i < chips.length; i++) {
          final chipWidth =
              _textWidth(chips[i], chipStyle, textScaler) + horizontalPadding;
          final gap = visibleChips.isNotEmpty ? spacing : 0;
          final isLast = i == chips.length - 1;

          // Reserve space for "..." when there are more chips after this one
          final needed = isLast
              ? gap + chipWidth
              : gap + chipWidth + spacing + ellipsisChipWidth;

          if (usedWidth + needed <= maxWidth) {
            usedWidth += gap + chipWidth;
            visibleChips.add(chips[i]);
          } else {
            overflow = true;
            break;
          }
        }

        return Row(
          children: [
            for (int i = 0; i < visibleChips.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              _buildChip(visibleChips[i], chipStyle),
            ],
            if (overflow) ...[
              SizedBox(width: spacing),
              _buildChip('...', chipStyle),
            ],
          ],
        );
      },
    );
  }

  double _textWidth(String text, TextStyle style, TextScaler textScaler) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    return tp.width.ceilToDouble();
  }

  Widget _buildChip(String label, TextStyle style) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: style),
    );
  }
}
