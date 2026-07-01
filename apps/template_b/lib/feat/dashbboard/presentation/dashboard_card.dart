import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';
import 'package:theme/theme.dart';

class DashboardCard extends BaseStatefulWidget {
  ServiceResponseModel serviceResponseModel;

  DashboardCard({required this.serviceResponseModel});

  @override
  ConsumerState<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends BaseStatefulWidgetState<DashboardCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticLabel = [
      widget.serviceResponseModel.label,
    ].where((s) => s != null && s.isNotEmpty).join(', ');
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () async {
          final action = widget.serviceResponseModel.action!
            ..tenantServiceId = widget.serviceResponseModel.id
            ..serviceSlug = widget.serviceResponseModel.slug
            ..serviceImage = widget.serviceResponseModel.serviceImage;
          await ref
              .read(templateBHandlerProvider)
              .executeAction(
                context,
                action,
                title: widget.serviceResponseModel.label,
              );
        },
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40.h,
                  width: 40.w,
                  child: CommonImage(
                    imagePath: widget.serviceResponseModel.serviceImage ?? '',
                    color: ref.watch(appThemeProvider).colors.surfaceLight,
                    fit: BoxFit.contain,
                  ),
                ),
                5.verticalSpace,
                CommonText(
                  titleText: widget.serviceResponseModel.label!,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    overflow: TextOverflow.ellipsis,
                    color: ref.watch(appThemeProvider).colors.surfaceLight,
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
