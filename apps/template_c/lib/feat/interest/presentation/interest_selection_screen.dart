import 'dart:async';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theme/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locale/locale.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/interest/controller/interest_sheet_controller.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_params.dart';
import 'package:template_c/feat/interest/state/interest_sheet_state.dart';

// sheet
void showInterestBottomSheet(
  BuildContext context, {
  InterestSelectionParams? interestSelectionParams,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => InterestSelectionContent(
      isSheet: true,
      interestSelectionParams: interestSelectionParams,
    ),
  );
}

//screen
class InterestSelectionScreen extends BaseStatelessWidget {
  final InterestSelectionParams interestSelectionParams;

  const InterestSelectionScreen({
    required this.interestSelectionParams,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'interest'.tr,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: InterestSelectionContent(
        interestSelectionParams: interestSelectionParams,
      ),
    );
  }
}

class InterestSelectionContent extends BaseStatefulWidget {
  final bool isSheet;
  final InterestSelectionParams? interestSelectionParams;

  const InterestSelectionContent({
    this.isSheet = false,
    this.interestSelectionParams,
    super.key,
  }) : assert(isSheet || interestSelectionParams != null);

  @override
  ConsumerState<InterestSelectionContent> createState() =>
      _InterestSelectionContentState();
}

class _InterestSelectionContentState
    extends BaseStatefulWidgetState<InterestSelectionContent> {
  String? _sheetMessage;
  bool _sheetMessageIsError = true;
  bool _sheetMessageVisible = false;
  Timer? _sheetHideTimer;

  void _showSheetMessage(String message, {bool isError = true}) {
    _sheetHideTimer?.cancel();
    setState(() {
      _sheetMessage = message;
      _sheetMessageIsError = isError;
      _sheetMessageVisible = true;
    });
    _sheetHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _sheetMessageVisible = false);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _sheetMessage = null);
        });
      }
    });
  }

  @override
  void dispose() {
    _sheetHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<InterestSheetState>(interestSheetControllerProvider, (
      previous,
      next,
    ) {
      final isNewError =
          (next.state == StateEnum.error &&
              previous?.state != StateEnum.error) ||
          (next.isLoadingSelectedInterestsError &&
              !(previous?.isLoadingSelectedInterestsError ?? false));

      if (isNewError) {
        String errorMsg = (next.message != null && next.message!.isNotEmpty)
            ? next.message!.tr
            : 'something_went_wrong'.tr;

        if (next.isLoadingSelectedInterestsError) {
          errorMsg = 'failed_to_load_config_selected_interest'.tr;
        }

        if (widget.isSheet) {
          _showSheetMessage(errorMsg, isError: true);
        } else {
          AppSnackBar.showError(context, errorMsg);
        }

        return;
      }

      if (next.state == StateEnum.success &&
          previous?.state != StateEnum.success) {
        if (context.mounted) {
          if (widget.isSheet) {
            _showSheetMessage('interests_saved_success'.tr, isError: false);
          } else {
            AppSnackBar.showSuccess(context, 'interests_saved_success'.tr);
          }
          widget.interestSelectionParams?.onConfirm(context);
        }
      }
    });

    final state = ref.watch(interestSheetControllerProvider);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final selectedIds = state.selectedIdList;
    final selectedTitles = state.selectedTitles;
    final isInitialLoading =
        state.loadingConfig || state.loadingSelectedInterests;
    final isApplying = state.state == StateEnum.loading;
    final isShowingLoader = isInitialLoading || isApplying;

    final content = Column(
      children: [
        if (widget.isSheet) ...[
          CommonBottomSheetHeader(
            title: 'interest'.tr,
            showBackButton: true,
            onBack: () => Navigator.of(context, rootNavigator: true).pop(),
            onClose: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          const Divider(),
        ],
        Expanded(
          child: state.isLoadingConfigError && state.data == null
              ? _configErrorView(state)
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      if (selectedTitles.isNotEmpty) ...[
                        _selectedFilters(
                          selectedIds: selectedIds,
                          idToTitle: state.idToTitle,
                          isApplying: isApplying,
                        ),
                        const Divider(),
                      ],
                      _categories(
                        state: state,
                        selectedIds: selectedIds,
                        isLoading: isInitialLoading,
                        isApplying: isApplying,
                      ),
                    ],
                  ),
                ),
        ),
        if (state.isConfigLoaded)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                'apply'.tr,
                borderRadius: 100.r,
                mainAxisSize: MainAxisSize.max,
                onPressed: () {
                  ref
                      .read(interestSheetControllerProvider.notifier)
                      .applySelectedInterest(widget.isSheet);
                },
              ),
            ),
          ),
      ],
    );

    return PopScope(
      canPop: !isShowingLoader,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: widget.isSheet
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.92,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: SafeArea(top: false, child: content),
                  )
                : SafeArea(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: surfaceColor,
                      child: content,
                    ),
                  ),
          ),
          if (isShowingLoader)
            Positioned.fill(
              child: AbsorbPointer(absorbing: true, child: TemplateCLoader()),
            ),
          if (widget.isSheet && _sheetMessage != null)
            Positioned(
              bottom: 75.h + MediaQuery.of(context).viewInsets.bottom,
              left: 15,
              right: 15,
              child: AnimatedSlide(
                offset: _sheetMessageVisible
                    ? Offset.zero
                    : const Offset(0, 1.5),
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                child: AnimatedOpacity(
                  opacity: _sheetMessageVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Material(
                    elevation: 6.0,
                    borderRadius: BorderRadius.circular(4.0),
                    color: _sheetMessageIsError
                        ? Theme.of(context).colorScheme.error
                        : (Theme.of(
                                context,
                              ).extension<AppErrorColors>()?.success ??
                              Colors.green),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: CommonText(
                        titleText: _sheetMessage!
                            .replaceAll('Exception:', '')
                            .trim(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _selectedFilters({
    required List<String> selectedIds,
    required Map<String, String> idToTitle,
    required bool isApplying,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: CommonText(
            titleText: "selected_filters".tr,
            textStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Wrap(
          spacing: 12.h,
          runSpacing: 12.h,
          children: selectedIds
              .map<Widget?>((id) {
                final title = idToTitle[id];
                if (title == null || title.isEmpty) return null;
                return Container(
                  height: 42.h,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonText(
                        titleText: title,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1.0,
                          color: Color(0xFF151B23),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: isApplying
                            ? null
                            : () {
                                final nextIds = Set<String>.from(selectedIds);
                                nextIds.remove(id);
                                _applySelectionUpdate(nextIds);
                              },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF151B23),
                        ),
                      ),
                    ],
                  ),
                );
              })
              .whereType<Widget>()
              .toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _categories({
    InterestSheetState? state,
    required List<String> selectedIds,
    required bool isLoading,
    required bool isApplying,
  }) {
    final categories = state?.data?.data ?? const [];

    if (isLoading && categories.isEmpty) {
      return const SizedBox.shrink();
    }

    if (categories.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: CommonText(
          titleText: 'no_interest_available'.tr,
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            height: 1.0,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in categories) ...[
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: CommonText(
              titleText: category.title ?? '',
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                height: 1.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: (category.children ?? const []).map((child) {
              final childId = child.id;
              final isSelected =
                  childId != null && selectedIds.contains(childId);

              return GestureDetector(
                onTap: isApplying
                    ? null
                    : () {
                        if (childId == null || childId.isEmpty) return;
                        final nextIds = Set<String>.from(selectedIds);
                        if (isSelected) {
                          nextIds.remove(childId);
                        } else {
                          nextIds.add(childId);
                        }
                        _applySelectionUpdate(nextIds);
                      },
                child: Container(
                  height: 42.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : const Color(0xFFF8F8F9),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : const Color(0xFFEAEAEA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      child.iconUrl != null
                          ? SvgPicture.network(
                              child.iconUrl!,
                              width: 16,
                              height: 16,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              size: 16,
                              color: const Color(0xFF151B23),
                            ),

                      SizedBox(width: 8.w),

                      CommonText(
                        titleText: child.title ?? '',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1.0,
                          color: const Color(0xFF151B23),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        SizedBox(height: 24.h),
      ],
    );
  }

  void _applySelectionUpdate(Set<String> nextIds) {
    ref
        .read(interestSheetControllerProvider.notifier)
        .updateSelected(nextIds.toList());
  }

  Widget _configErrorView(InterestSheetState state) {
    final errorMsg = 'failed_to_load_config'.tr;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.w,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16.h),
            CommonText(
              titleText: errorMsg,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(
              'retry'.tr,
              borderRadius: 100.r,
              onPressed: () {
                ref
                    .read(interestSheetControllerProvider.notifier)
                    .getInterestConfig();
              },
            ),
          ],
        ),
      ),
    );
  }
}
