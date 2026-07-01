import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:common_components/common_components.dart';

class RecentSearchView extends StatelessWidget {
  const RecentSearchView({
    super.key,
    required this.queries,
    required this.onItemTap,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<String> queries;
  final ValueChanged<String> onItemTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                titleText : 'recent_searches_title'.tr,
                textStyle: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              if (queries.isNotEmpty)
                GestureDetector(
                  onTap: onClearAll,
                  child: Text(
                    'recent_searches_clear'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      decoration: TextDecoration.underline,
                      decorationColor: textColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (queries.isNotEmpty)
          ...queries.map(
            (query) => _RecentSearchItemRow(
              title: query,
              onTap: () => onItemTap(query),
              onRemove: () => onRemove(query),
            ),
          ),
      ],
    );
  }
}

class _RecentSearchItemRow extends StatelessWidget {
  const _RecentSearchItemRow({
    required this.title,
    required this.onTap,
    required this.onRemove,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          children: [
            _buildLeading(context),
            SizedBox(width: 12.w),
            Expanded(
              child: CommonText(
                titleText: title,
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12.w,),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                child: Icon(
                  Icons.close,
                  size: 15.h,
                  color: TemplateCColors.textAndIconGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLight
        ? TemplateCColors.textDark
        : TemplateCColors.textAndIconWhite;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: SvgPicture.asset(
        'assets/svg/search.svg',
        width: 25.h,
        height: 25.h,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }
}
