import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/core/widgets/app_image_card.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/services/presentation/controller/service_controller.dart';
import 'package:go_router/go_router.dart';

class ServiceHubScreenParams {
  final String tabSlug;
  final String title;

  const ServiceHubScreenParams({
    required this.tabSlug,
    this.title = '',
  });
}

class ServiceHubScreen extends ConsumerStatefulWidget {
  final ServiceHubScreenParams params;

  const ServiceHubScreen({super.key, required this.params});

  @override
  ConsumerState<ServiceHubScreen> createState() => _ServiceHubScreenState();
}

class _ServiceHubScreenState extends ConsumerState<ServiceHubScreen> {
  String get _key => widget.params.tabSlug;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(serviceControllerProvider(_key).notifier)
          .fetchServices(limit: 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceControllerProvider(_key));
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final iconColor = Theme.of(context).colorScheme.onSurface;
    final title = widget.params.title;

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
        title: title.isNotEmpty
            ? CommonText(
                titleText: title,
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
      body: switch (state.configState) {
        StateConstant.loading => const Center(child: CircularProgressIndicator()),
        StateConstant.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  titleText: 'error_loading'.tr,
                  textStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
                ),
                SizedBox(height: 16.h),
                OutlinedButton(
                  onPressed: () => ref
                      .read(serviceControllerProvider(_key).notifier)
                      .refresh(),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          ),
        StateConstant.success => state.services.isEmpty
            ? Center(
                child: CommonText(
                  titleText: 'no_data'.tr,
                  textStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(serviceControllerProvider(_key).notifier)
                    .refresh(),
                color: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.primary,
                child: ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  itemCount: state.services.length,
                  separatorBuilder: (_, __) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    final item = state.services[index];
                    Color tagBgColor =
                        Theme.of(context).colorScheme.secondary;
                    final hex = item.titleBackgroundColor;
                    if (hex != null && hex.isNotEmpty) {
                      try {
                        tagBgColor = Color(
                            int.parse(hex.replaceFirst('#', '0xff')));
                      } catch (_) {}
                    }
                    return AppImageCard(
                      imageUrl: item.serviceImage ?? '',
                      height: 240.h,
                      tagText: item.label ?? item.title ?? '',
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
                              .executeAction(
                                context,
                                ActionResponseModel().fromJson(
                                    item.action!.toJson()),
                                title: item.label ?? item.title,
                              ),
                    );
                  },
                ),
              ),
      },
    );
  }
}
