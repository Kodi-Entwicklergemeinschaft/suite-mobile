import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:theme/theme.dart';

import '../../base/base_stateful_widget.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_icon.dart';
import '../../widgets/common_text.dart';
import '../../widgets/multi_drop_down/multi_dropdown.dart';
import '../controller/locality_selection_controller.dart';
import '../data/model/locality_delivery_model.dart';
import '../data/model/locality_model.dart';
import '../state/locality_selection_state.dart';

/// Abstract base — subclasses provide [serviceSlug] and implement [onConfirmed].
/// All UI and controller logic lives here; navigation stays in the subclass.
abstract class LocalitySelectionScreen extends BaseStatefulWidget {
  const LocalitySelectionScreen({super.key});

  String get serviceSlug;

  void onConfirmed(
    BuildContext context,
    WidgetRef ref,
    LocalityDeliveryModel delivery,
    LocalityModel selectedLocation,
  );
}

abstract class LocalitySelectionScreenState<T extends LocalitySelectionScreen>
    extends BaseStatefulWidgetState<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(localitySelectionControllerProvider.notifier)
          .initialize(widget.serviceSlug);
    });
  }

  Future<void> _onConfirm(LocalitySelectionState state) async {
    final delivery = await ref
        .read(localitySelectionControllerProvider.notifier)
        .confirmLocation();
    if (!mounted || delivery == null) return;
    widget.onConfirmed(context, ref, delivery, state.selectedLocation!);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localitySelectionControllerProvider);
    final appTheme = ref.watch(appThemeProvider);
    final isSelected = state.selectedLocation != null;
    final isLoading = state.status == LocalitySelectionStatus.loading ||
        state.status == LocalitySelectionStatus.confirming;

    return Scaffold(
      appBar: CommonAppBar(
        title: 'dt_select_location'.tr,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        24.verticalSpace,
                        _buildDropdown(context, state, appTheme),
                        if (state.recentLocations.isNotEmpty) ...[
                          24.verticalSpace,
                          _buildRecentSection(state, appTheme),
                        ],
                        24.verticalSpace,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      'dt_confirm'.tr,
                      disabled: !isSelected || isLoading,
                      onPressed: isSelected && !isLoading
                          ? () => _onConfirm(state)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    LocalitySelectionState state,
    AppTheme appTheme,
  ) {
    final isLoading = state.status == LocalitySelectionStatus.loading;
    final isError = state.status == LocalitySelectionStatus.error;

    final items = isLoading || isError
        ? <MultiSelectItem<LocalityModel>>[]
        : state.allLocations
            .map(
              (loc) =>
                  MultiSelectItem<LocalityModel>(value: loc, label: loc.name),
            )
            .toList();

    final hint = isLoading
        ? '...'
        : isError
            ? (state.errorMessage ?? 'dt_location_load_error').tr
            : 'dt_select_location'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dt_location'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.inverseSurface.withValues(
                  alpha: 0.7,
                ),
          ),
        ),
        4.verticalSpace,
        MultiSelectDropdown<LocalityModel>(
          items: items,
          hint: hint,
          searchHint: 'dt_select_location'.tr,
          noItemsFoundText: 'no_localities_found'.tr,
          maxSelection: 1,
          maxVisibleChips: 1,
          width: MediaQuery.of(context).size.width - 32.w,
          initialValues:
              state.selectedLocation != null ? [state.selectedLocation!] : null,
          dropdownDecoration: MultiSelectDropdownDecoration(maxHeight: 400.h),
          decoration: MultiSelectDecoration(
            height: 48.h,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 4.h,
            ),
            border: BorderSide(
              color: Theme.of(context).colorScheme.inverseSurface.withValues(
                    alpha: 0.5,
                  ),
            ),
            borderRadius: BorderRadius.circular(5.r),
          ),
          onSelectionChanged: (selected) {
            if (selected.isNotEmpty) {
              ref
                  .read(localitySelectionControllerProvider.notifier)
                  .selectLocation(selected.first);
            } else {
              ref
                  .read(localitySelectionControllerProvider.notifier)
                  .clearSelection();
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecentSection(LocalitySelectionState state, AppTheme appTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          titleText: 'dt_recent_searches'.tr,
          textStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.inverseSurface.withValues(
                  alpha: 0.55,
                ),
          ),
        ),
        8.verticalSpace,
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 280.h),
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: state.recentLocations
                .map(
                  (loc) => _RecentLocationTile(
                    location: loc,
                    isSelected: state.selectedLocation?.id == loc.id,
                    primaryColor: appTheme.colors.primary,
                    onTap: () => ref
                        .read(localitySelectionControllerProvider.notifier)
                        .selectLocation(loc),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _RecentLocationTile extends StatelessWidget {
  final LocalityModel location;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _RecentLocationTile({
    required this.location,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 18.h,
              color: isSelected
                  ? primaryColor
                  : Theme.of(context).colorScheme.inverseSurface.withValues(
                        alpha: 0.45,
                      ),
            ),
            10.horizontalSpace,
            Expanded(
              child: CommonText(
                titleText: location.name,
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? primaryColor
                      : Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, size: 16.h, color: primaryColor),
          ],
        ),
      ),
    );
  }
}
