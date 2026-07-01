import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';
import 'package:template_b/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_b/routes/app_routes.dart';

class CategoryWidget extends StatefulWidget {
  final List<ServiceResponseModel> items;
  final Function(ServiceResponseModel)? onItemTap;
  final VoidCallback? onShowMore;
  final String? label;

  const CategoryWidget({
    super.key,
    required this.items,
    this.onItemTap,
    this.onShowMore,
    this.label,
  });

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox.shrink();
    }

    final hasMore = widget.items.length > 8;
    // Show 7 items + 1 "more" button = 8 total (2 rows of 4)
    final itemsToShow = hasMore ? 7 : widget.items.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.w,
        runSpacing: 16.h,
        children: [
          // Show first 8 items (or all if less than 8)
          ...widget.items.take(itemsToShow).map((item) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 32.w - 24.w) / 4,
              child: Semantics(
                button: true,
                label: item.label ?? '',
                child: GestureDetector(
                  onTap: () => widget.onItemTap?.call(item),
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: CommonImage(
                              imagePath: item.icon ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Flexible(
                          child: CommonText(
                            titleText: item.label ?? '',
                            textStyle: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          // Show more button at position 8 if items > 8
          if (hasMore)
            SizedBox(
              width: (MediaQuery.of(context).size.width - 32.w - 24.w) / 4,
              child: Semantics(
                button: true,
                label: 'show_all'.tr,
                child: GestureDetector(
                  onTap: () {
                    // If custom callback provided, use it; otherwise navigate to SubServiceScreen
                    if (widget.onShowMore != null) {
                      widget.onShowMore!();
                    } else if (widget.label != null) {
                      context.pushNamed(
                        AppRouteConstants.subService.name,
                        extra: SubServiceScreenParams(
                          title: widget.label!,
                          services: widget.items,
                        ),
                      );
                    }
                  },
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(Icons.add, size: 20.sp),
                        ),
                        SizedBox(height: 4.h),
                        CommonText(
                          titleText: 'more',
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
