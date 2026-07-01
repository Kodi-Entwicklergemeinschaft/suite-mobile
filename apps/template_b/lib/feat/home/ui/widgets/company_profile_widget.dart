import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:theme/theme.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:template_b/feat/home/controller/home_controller.dart';
import 'package:template_b/feat/home/state/home_state.dart';
import '../../data/models/company_profile_model.dart';
import 'package:go_router/go_router.dart';

class CompanyProfileWidget extends BaseStatefulWidget {
  final String? title;
  final int maxItems;
  final String? category;
  final String? description;
  final bool requireShortCode;
  final bool requiredLogin;

  const CompanyProfileWidget({
    super.key,
    this.title,
    this.requiredLogin = false,
    this.maxItems = 5,
    this.category,
    this.description,
    this.requireShortCode = false,
  });

  @override
  ConsumerState<CompanyProfileWidget> createState() =>
      _CompanyProfileWidgetState();
}

class _CompanyProfileWidgetState
    extends BaseStatefulWidgetState<CompanyProfileWidget> {
  void _handleCompanyTap(CompanyProfileModel company) {
    final isLoggedIn = ref.watch(authStateProvider);

    // If login required but not logged in, show login sheet
    if (widget.requiredLogin == true && !isLoggedIn) {
      CommonSheet.show(
        ref.context,
        title: 'sign_in'.tr,
        content: 'please_login_to_continue'.tr,
        confirmButtonText: 'sign_in'.tr,
        cancelButtonText: 'cancel'.tr,
        onConfirm: () {
          if (ref.context.mounted) {
            ref.context.pushNamed(AppRouteConstants.signIn.name);
          }
        },
      );
      return null;
    }
    // Open company profile URL
    final urlToOpen = company.companyProfileUrl;
    if (urlToOpen != null && urlToOpen.isNotEmpty) {
      final launcherHandlerInstance = ref.read(launcherHandler);
      launcherHandlerInstance.executeAction(
        context,
        urlToOpen,
        shortCodeRequired: widget.requireShortCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(homeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        if (widget.title != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.description?.isNotEmpty == true ? 3.h : 8.h,
            ),
            child: CommonText(
              titleText: widget.title!,
              isHeader: true,
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
              overflow: TextOverflow.visible,
            ),
          ),

        // Description
        if (widget.description?.isNotEmpty == true)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CommonText(
              titleText: widget.description!,
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
            ),
          ),

        // Content states
        if (state.isLoadingCompanyProfiles)
          _buildShimmer()
        else if (state.companyProfilesError != null)
          _buildErrorState(theme)
        else if (state.companyProfiles.isEmpty)
          _buildEmptyState(theme)
        else
          _buildCompanyList(state),
      ],
    );
  }

  // Horizontal company list
  Widget _buildCompanyList(HomeState state) {
    return SizedBox(
      height: 126.h,
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: state.companyProfiles.take(widget.maxItems).length,
        itemBuilder: (context, index) {
          final company = state.companyProfiles[index];
          return _buildCompactCard(company);
        },
      ),
    );
  }

  // Compact card (matches LocalityWidget slider style)
  Widget _buildCompactCard(CompanyProfileModel company) {
    return Builder(
      builder: (context) {
        final appTheme = ref.watch(appThemeProvider);
        final semanticLabel = [
          company.name,
        ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

        return SizedBox(
          width: 103.w,
          child: Semantics(
            button: true,
            label: semanticLabel,
            child: GestureDetector(
              onTap: () => _handleCompanyTap(company),
              child: ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Stack(
                    children: [
                      // Company image/logo
                      CommonImage(
                        imagePath: company.image ?? '',
                        width: 103.w,
                        height: 126.h,
                        fit: BoxFit.cover,
                        label: 'Company profile ${company.name}',
                      ),
                      // Gradient overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(
                                  context,
                                ).colorScheme.scrim.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Company name at bottom
                      if (company.name != null)
                        Positioned(
                          bottom: 8.h,
                          left: 8.w,
                          right: 8.w,
                          child: CommonText(
                            titleText: company.name!,
                            textStyle: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: appTheme.colors.surfaceLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Loading shimmer
  Widget _buildShimmer() {
    return SizedBox(
      height: 126.h,
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: widget.maxItems,
        itemBuilder: (context, index) {
          return CommonShimmer(
            enabled: true,
            child: Container(
              width: 103.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        },
      ),
    );
  }

  // Error state
  Widget _buildErrorState(ThemeData theme) {
    return SizedBox(
      height: 126.h,
      child: Center(
        child: Icon(
          Icons.error_outline,
          size: 48,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 126.h,
      child: Center(
        child: Icon(
          Icons.inbox_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
