import 'dart:developer';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/core/utils/utility_methods.dart';
import 'package:template_c/feat/handler/template_c_handler.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/controller/home_controller.dart';
import 'package:template_c/feat/home/data/models/home_config.dart';
import 'package:template_c/feat/home/state/home_state.dart';
import 'package:template_c/feat/home/widgets/banner_widget.dart';
import 'package:template_c/feat/home/widgets/home_action_card.dart';
import 'package:template_c/feat/home/widgets/listing/listing_widget.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';

class HomeDefaultView extends BaseStatelessWidget {
  final HomeState state;

  const HomeDefaultView({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = ref.watch(preferenceManagerProvider);
    final savedLocation = pref.getStringOrNull(StorageKeys.selectedLocation);

    final widgets = <Widget>[];

    const int bannerInjectAfterIndex = 1; // inject after 2nd visible component
    final banner = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: HeadlineBannerWidget(onActionTap: () {}),
    );

    final isGuest =
        pref.getStringOrEmpty(StorageKeys.authRole) == UserRole.guest.value;
    final isBannerVisible =
        isGuest && !(ref.watch(homeControllerProvider).isConfigLoading);

    HomeScreenConstant? prevVariant;
    int visibleIndex = 0;
    bool bannerInserted = false;
    bool skipNextDivider = false;

    for (final component in state.components) {
      if (!component.visible) continue;

      final isV1 = component.variant == HomeScreenConstant.contentSliderV1;
      final prevWasV1 = prevVariant == HomeScreenConstant.contentSliderV1;

      if (widgets.isNotEmpty && !isV1 && !prevWasV1 && !skipNextDivider) {
        widgets.add(Divider(height: 120.h, thickness: 8.h));
      } else if (widgets.isNotEmpty && !skipNextDivider) {
        widgets.add(SizedBox(height: 60.h));
      }
      skipNextDivider = false;

      widgets.add(_buildComponent(context, ref, component, savedLocation));

      // Inject banner after the component at bannerInjectAfterIndex
      if (visibleIndex == bannerInjectAfterIndex && !bannerInserted) {
        widgets.add(banner);
        bannerInserted = true;
        if (isBannerVisible) skipNextDivider = true;
      }

      prevVariant = component.variant;
      visibleIndex++;
    }

    // Fallback: if fewer than 3 components, show banner at end
    if (!bannerInserted) {
      widgets.add(banner);
    }

    widgets.add(SizedBox(height: 120.h));

    return RefreshIndicator(
      onRefresh: () async {
        final freshComponents = await ref
            .read(homeControllerProvider.notifier)
            .refreshDefaultView();
        log(
          'Home Screen refresh keys ${freshComponents.map((e) => e.key).toList()}',
          name: 'ListingWidget',
        );
        await Future.wait([
          for (final entry in freshComponents)
            ref
                .read(listingControllerProvider(entry.key).notifier)
                .getListing(entry.filter),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            ...widgets,
          ],
        ),
      ),
    );
  }

  Widget _buildComponent(
    BuildContext context,
    WidgetRef ref,
    ContentSliderConfig component,
    String? savedLocation,
  ) {
    final isV1 = component.variant == HomeScreenConstant.contentSliderV1;
    final filterKey = component.uniqueKey;
    final filter = component.toListingFilter();
    final title = resolveLabel(
      component.label,
      selectedLocation: savedLocation,
    );

    // Non-category action or inline items list — render HomeActionCard,
    // never fetch listings.
    final action = component.action;
    final hasInlineItems =
        component.items != null && component.items!.isNotEmpty;
    final isDirectAction =
        action != null && action.type != null && action.type != 'category';
    if (isDirectAction || hasInlineItems) {
      return HomeActionCard(config: component);
    }

    // V1 (highlights) — no action, no see-all
    if (isV1) {
      return ListingWidget(
        variant: component.variant,
        filterKey: filterKey,
        initialFilter: filter,
        sectionTitle: title,
        showActionChevron: false,
      );
    }

    // V2 / V3 — wire see-all through the template handler
    final handler = ref.read(templateCHandlerProvider);

    return ListingWidget(
      key: Key(title),
      variant: component.variant,
      filterKey: filterKey,
      initialFilter: filter,
      sectionTitle: title,
      actionLabel: 'home_all_events'.tr,
      onSeeAllTap: action != null
          ? () => handler.executeAction(
              context,
              action,
              title: title,
              filter: filter,
              familyKey: filterKey,
            )
          : null,
    );
  }
}
