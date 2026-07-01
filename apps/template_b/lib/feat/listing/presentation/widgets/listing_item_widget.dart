import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import '../../data/models/listing_model.dart';
import '../../../../core/utils/listing_utils.dart';

import 'package:html/parser.dart' as html_parser;

/// Reusable listing item widget - can be used in list or section
class ListingItemWidget extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onTap;

  const ListingItemWidget({super.key, required this.listing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final semanticLabel = [
      listing.title,
      _getDateRange(),
      stripHtmlTags(listing.summary ?? ''),
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(8.r),
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey, width: 0.2.w),
                  ),
                  width: 103.w,
                  height: 126.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CommonImage(
                      imagePath: (listing.heroImageUrl?.isNotEmpty == true)
                          ? listing.heroImageUrl!
                          : (listing.categoryFallbackImage ?? ''),
                      width: 103.w,
                      height: 126.h,
                      fit: BoxFit.cover,
                      errorWidget:
                          (listing.heroImageUrl?.isNotEmpty == true &&
                              listing.categoryFallbackImage?.isNotEmpty == true)
                          ? (context, error, stack) => CommonImage(
                              imagePath: listing.categoryFallbackImage!,
                              width: 103.w,
                              height: 126.h,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 24.w),
                // Item Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title (FIRST)
                      CommonText(
                        titleText: listing.title ?? '',
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 8.h),
                      // Date Badge using primary color (SECOND)
                      if (_getDateRange() != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: CommonText(
                            titleText: _getDateRange()!,
                            textStyle: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_getDateRange() != null) SizedBox(height: 8.h),

                      // Description (THIRD)
                      CommonText(
                        titleText: stripHtmlTags(listing.summary ?? ''),
                        textStyle: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 3,
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

  String stripHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  String? _getDateRange() {
    return getDateRange(listing);
  }
}
