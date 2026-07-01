import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/utils/string_extensions.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/core/widgets/template_search_bar.dart';
import 'package:template_a/feat/category/presentation/category_screen.dart';
import 'package:template_a/feat/discover/presentation/widgets/discover_card.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/services/data/models/service_response_model.dart';
import 'package:template_a/feat/services/presentation/controller/service_controller.dart';

const _kProviderKey = 'discover_screen';

class DiscoverScreen extends BaseStatefulWidget {
  final String? tabSlug;
  const DiscoverScreen({super.key, this.tabSlug});

  @override
  String? get screenName => tabSlug;

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends BaseStatefulWidgetState<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(serviceControllerProvider(_kProviderKey).notifier).fetchServices(limit: 20),
    );
  }

  Future<void> _onRefresh() {
    return ref
        .read(serviceControllerProvider(_kProviderKey).notifier)
        .fetchServices(limit: 20);
  }

  bool _shouldShowItem(ServiceResponseModel item, bool isGuest) {
    if (item.action?.config?.isVisible == false) return false;
    final login = item.action?.config?.requireLogin ?? false;
    final guestOnly = item.action?.config?.isGuestOnly ?? false;
    if (login && !guestOnly) return !isGuest;  // logged-in only
    if (!login && guestOnly) return isGuest;   // guest only
    return true;                               // both false → show for everyone
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(serviceControllerProvider(_kProviderKey));
    final isGuest = ref.read(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);
    final theme = Theme.of(context);

    Widget body;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = (screenWidth - 60.w) / 1.5;

    if (serviceState.configState == StateConstant.loading) {
      body = ShimmerWidget(
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 32.h),
          itemCount: 4,
          separatorBuilder: (_, __) => SizedBox(height: 20.h),
          itemBuilder: (context, __) => Container(
            height: cardHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      );
    } else if (serviceState.configState == StateConstant.error) {
      body = Center(
        child: CommonText(
          titleText: 'error_loading'.tr,
          textStyle: theme.textTheme.bodyLarge,
        ),
      );
    } else {
      final filteredItems = serviceState.services
          .where((item) => _shouldShowItem(item, isGuest))
          .toList();

      if (filteredItems.isEmpty) {
        body = Center(
          child: CommonText(
            titleText: 'no_data'.tr,
            textStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
        );
      } else {
      body = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 32.h),
        itemCount: filteredItems.length,
        separatorBuilder: (_, __) => SizedBox(height: 20.h),
        itemBuilder: (_, i) {
          final item = filteredItems[i];
          final tagBgColor = item.titleBackgroundColor.isNotNullAndEmpty
              ? item.titleBackgroundColor.hexToColor
              : theme.colorScheme.secondary;
          return DiscoverCard(
            imageUrl: item.serviceImage ?? '',
            height: cardHeight,
            tagText: item.title,
            tagBgColor: tagBgColor,
            tagIconUrl: item.icon,
            tagFontSize: 20,
            titleText: item.subtitle,
            titleBgColor: tagBgColor,
            subtitleText: item.description,
            onTap: () {
              if (item.action?.type != null) {
                ref.read(templateAHandlerProvider).executeAction(
                  context,
                  item.action!,
                  title: item.title,
                );
              } else if (item.slug != null) {
                context.go(
                  '/shell/discover/category',
                  extra: CategoryScreenParams(
                    categorySlug: item.slug!,
                    screenTitle: item.title ?? '',
                    headerColorHex: item.titleBackgroundColor,
                  ),
                );
              }
            },
          );
        },
      );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(30.w, 16.h, 30.w, 0),
              child: TemplateSearchBar(hintText: 'search'.tr, showFilterButton: false),
            ),
            SizedBox(height: 28.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.primary,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
