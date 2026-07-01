import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/core/widgets/template_chip.dart';
import 'package:template_c/feat/search/controller/search_controller.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:template_c/feat/search/filter/search_filter_controller.dart';
import 'package:go_router/go_router.dart';

void showSearchFilterSheet(
  BuildContext context, {
  required VoidCallback onDateRemoved,
  required VoidCallback onFreeEntryRemoved,
  required VoidCallback onLocationRemoved,
  String? focusGroupId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => SearchFilterSheet(
      onDateRemoved: onDateRemoved,
      onFreeEntryRemoved: onFreeEntryRemoved,
      onLocationRemoved: onLocationRemoved,
      focusGroupId: focusGroupId,
    ),
  );
}

class SearchFilterSheet extends BaseStatefulWidget {
  const SearchFilterSheet({
    super.key,
    required this.onDateRemoved,
    required this.onFreeEntryRemoved,
    required this.onLocationRemoved,
    this.focusGroupId,
  });

  final VoidCallback onDateRemoved;
  final VoidCallback onFreeEntryRemoved;
  final VoidCallback onLocationRemoved;
  final String? focusGroupId;

  @override
  ConsumerState<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState
    extends BaseStatefulWidgetState<SearchFilterSheet> {
  late List<String> _initialSlugs;

  @override
  void initState() {
    super.initState();
    // Snapshot slugs at open time to detect changes on close
    _initialSlugs = ref
        .read(searchFilterControllerProvider)
        .selectedInterests
        .map((e) => e.slug ?? '')
        .toList();
    Future.microtask(
      () => ref.read(searchFilterControllerProvider.notifier).loadInterests(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;

    final filterState = ref.watch(searchFilterControllerProvider);
    final isLoading = filterState.stateConstant == StateConstant.loading;
    final isInitialLoading = isLoading && filterState.groups.isEmpty;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(36),
                topRight: Radius.circular(36),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, dividerColor),
                  if (!isInitialLoading)
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SelectedFiltersSection(
                              onDateRemoved: widget.onDateRemoved,
                              onFreeEntryRemoved: widget.onFreeEntryRemoved,
                              onLocationRemoved: widget.onLocationRemoved,
                            ),
                            _InterestGroupsSection(
                              focusGroupId: widget.focusGroupId,
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(absorbing: true, child: TemplateCLoader()),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color dividerColor) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 20.h),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: CommonText(
                    titleText: 'fav_filter_title'.tr,
                    textStyle: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final currentSlugs = ref
                      .read(searchFilterControllerProvider)
                      .selectedInterests
                      .map((e) => e.slug ?? '')
                      .toList();

                  final changed =
                      currentSlugs.length != _initialSlugs.length ||
                      !currentSlugs.every(_initialSlugs.contains);

                  if (changed) {
                    ref
                        .read(searchControllerProvider.notifier)
                        .updateCategoryFilter(currentSlugs);
                  }
                  context.pop();
                },
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dividerColor.withValues(alpha: 0.3),
                  ),
                  child: Icon(Icons.close, size: 18.sp, color: textColor),
                ),
              ),
            ],
          ),
        ),
        Divider(color: dividerColor, height: 1, thickness: 1),
      ],
    );
  }
}

// ── Selected filters section ───────────────────────────────────────────────

class _SelectedFiltersSection extends BaseStatelessWidget {
  const _SelectedFiltersSection({
    required this.onDateRemoved,
    required this.onFreeEntryRemoved,
    required this.onLocationRemoved,
  });

  final VoidCallback onDateRemoved;
  final VoidCallback onFreeEntryRemoved;
  final VoidCallback onLocationRemoved;

  String? _formatDate(DateTimeRange? range) {
    if (range == null) return null;
    final pad = (int n) => n.toString().padLeft(2, '0');
    final s = range.start;
    final e = range.end;
    return '${pad(s.day)}.${pad(s.month)} – ${pad(e.day)}.${pad(e.month)}';
  }

  String _fullLocationLabel(String? address) {
    final normalized = address?.trim() ?? '';
    if (normalized.isEmpty) return 'filter_location'.tr;
    return normalized;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);
    final filterState = ref.watch(searchFilterControllerProvider);
    final filterController = ref.read(searchFilterControllerProvider.notifier);

    final selectedInterests = filterState.selectedInterests;
    final dateLabel = _formatDate(searchState.dateFilter);
    final hasFreeEntry = searchState.isFreeEntryFilterActive;
    final hasLocation = searchState.isLocationFilterActive;
    final locationLabel = _fullLocationLabel(searchState.filterLocationName);

    final hasAny =
        selectedInterests.isNotEmpty ||
        dateLabel != null ||
        // hasFreeEntry ||
        hasLocation;

    if (!hasAny) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        CommonText(
          titleText: 'search_filter_selected'.tr,
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            // Interest chips
            ...selectedInterests.map(
              (interest) => _ActiveChip(
                label: interest.title ?? '',
                iconUrl: interest.iconUrl,
                onRemove: () => filterController.removeInterest(interest),
              ),
            ),
            // Date chip
            if (dateLabel != null)
              _ActiveChip(
                label: dateLabel,
                onRemove: () {
                  onDateRemoved();
                },
              ),
            // Free entry chip
            // if (hasFreeEntry)
            //   _ActiveChip(
            //     label: 'filter_free_entry'.tr,
            //     onRemove: onFreeEntryRemoved,
            //   ),
            // Location chip
            if (hasLocation)
              _ActiveChip(label: locationLabel, onRemove: onLocationRemoved),
          ],
        ),
        SizedBox(height: 16.h),
        Divider(
          color: Theme.of(context).dividerTheme.color,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({
    required this.label,
    required this.onRemove,
    this.iconUrl,
  });

  final String label;
  final VoidCallback onRemove;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final onSecondary = Theme.of(context).colorScheme.onSecondary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final maxChipWidth = MediaQuery.of(context).size.width - 32.w - 32.w;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxChipWidth),
      child: Container(
        height: 42.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: onSecondary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 16, color: onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Interest groups section ────────────────────────────────────────────────

class _InterestGroupsSection extends BaseStatelessWidget {
  const _InterestGroupsSection({this.focusGroupId});

  final String? focusGroupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchFilterControllerProvider);

    if (state.stateConstant == StateConstant.loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.stateConstant == StateConstant.error) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: CommonText(
            titleText: state.errorMessage,
            textStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: state.groups.map((group) {
        return _InterestGroup(
          group: group,
          autoScroll: focusGroupId != null && group.id == focusGroupId,
        );
      }).toList(),
    );
  }
}

class _InterestGroup extends BaseStatefulWidget {
  const _InterestGroup({required this.group, this.autoScroll = false});

  final InterestConfigCategories group;
  final bool autoScroll;

  @override
  ConsumerState<_InterestGroup> createState() => _InterestGroupState();
}

class _InterestGroupState extends BaseStatefulWidgetState<_InterestGroup> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _key.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(searchFilterControllerProvider.notifier);

    return Column(
      key: _key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        CommonText(
          titleText: widget.group.title ?? '',
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: (widget.group.children ?? []).map((interest) {
            return _InterestChip(
              interest: interest,
              isSelected: ref.watch(
                searchFilterControllerProvider.select(
                  (s) => s.selectedInterests.contains(interest),
                ),
              ),
              onTap: () => controller.toggleInterest(interest),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  final InterestCategoriesChildern interest;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TemplateChip(
      label: interest.title ?? '',
      isActive: isSelected,
      onTap: onTap,
      prefixIcon: interest.iconUrl != null
          ? CommonImage(
              imagePath: interest.iconUrl!,
              width: 16.w,
              height: 16.h,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).textTheme.bodyMedium?.color,
            )
          : null,
    );
  }
}
