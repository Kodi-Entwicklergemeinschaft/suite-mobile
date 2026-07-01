import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import '../../data/models/home_config.dart';

class PartnersWidget extends BaseStatelessWidget {
  final PartnersConfig config;

  const PartnersWidget({super.key, required this.config});

  void _handleTap(BuildContext context, WidgetRef ref, PartnerItem item) {
    if (item.action != null) {
      ref
          .read(templateBHandlerProvider)
          .executeAction(context, item.action!, title: item.label);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = config.items;
    if (items.isEmpty) return const SizedBox.shrink();

    final first = items.first;
    final rest = items.skip(1).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          if (config.label != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: CommonText(
                titleText: config.label!,
                isHeader: true,
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

          // First item — full width
          Semantics(
            button: first.action != null,
            label: first.label ?? '',
            child: GestureDetector(
              onTap: () => _handleTap(context, ref, first),
              child: ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CommonImage(
                    imagePath: first.image ?? '',
                    width: double.infinity,
                    height: 120.h,
                    fit: BoxFit.contain,
                    label: first.label ?? '',
                  ),
                ),
              ),
            ),
          ),

          // Remaining items — pairs of 2 per row
          if (rest.isNotEmpty)
            ...List.generate((rest.length / 2).ceil(), (rowIndex) {
              final rowStart = rowIndex * 2;
              final rowItems = rest.skip(rowStart).take(2).toList();
              return Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    for (int i = 0; i < rowItems.length; i++) ...[
                      if (i > 0) SizedBox(width: 8.w),
                      Expanded(
                        child: Semantics(
                          button: rowItems[i].action != null,
                          label: rowItems[i].label ?? '',
                          child: GestureDetector(
                            onTap: () => _handleTap(context, ref, rowItems[i]),
                            child: ExcludeSemantics(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: CommonImage(
                                  imagePath: rowItems[i].image ?? '',
                                  width: double.infinity,
                                  height: 120.h,
                                  fit: BoxFit.contain,
                                  label: rowItems[i].label ?? '',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Fill empty slot if odd number in row
                    if (rowItems.length == 1) Expanded(child: SizedBox()),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
