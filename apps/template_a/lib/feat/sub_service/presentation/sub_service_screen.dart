import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/core/widgets/app_image_card.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/router/route_constant.dart';

class SubServiceScreenParams {
  final String title;
  final List<ServiceItemModel> services;
  final String tabSlug;

  SubServiceScreenParams({required this.title, required this.services, this.tabSlug = ''});
}

class SubServiceScreen extends BaseStatelessWidget {
  final SubServiceScreenParams params;

  const SubServiceScreen({super.key, required this.params});

  @override
  String get screenName => RouteConstant.subService.name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Semantics(
          button: true,
          label: 'back_button_label'.tr,
          child: IconButton(
            icon: ExcludeSemantics(
              child: Icon(Icons.arrow_back_ios, color: iconColor),
            ),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              itemCount: params.services.length,
              separatorBuilder: (_, __) => SizedBox(height: 20.h),
              itemBuilder: (context, index) {
                final item = params.services[index];
                final theme = Theme.of(context);
                Color tagBgColor = theme.colorScheme.secondary;
                final hex = item.titleBackgroundColor;
                if (hex != null && hex.isNotEmpty) {
                  try { tagBgColor = Color(int.parse(hex.replaceFirst('#', '0xff'))); } catch (_) {}
                }
                return AppImageCard(
                  imageUrl: item.image ?? '',
                  height: 240.h,
                  tagText: item.label ?? '',
                  tagBgColor: tagBgColor,
                  tagTopOffset: 8.h,
                  tagBorderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(6.r),
                  ),
                  tagMaxWidthFraction: 0.9,
                  tagFontSize: 18,
                  showBottomGradient: false,
                  shadowOpacity: 0.12,
                  shadowOffset: const Offset(0, 2),
                  onTap: item.action == null
                      ? null
                      : () => ref
                          .read(templateAHandlerProvider)
                          .executeAction(context, item.action!, title: item.label, tabSlug: params.tabSlug),
                );
              },
            ),
    );
  }
}
