import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/core/utils/string_extensions.dart';
import 'package:template_a/feat/search/controller/search_controller.dart';
import 'package:template_a/feat/search/state/search_state.dart';
import 'package:template_a/router/route_constant.dart';

class SearchScreen extends BaseStatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  String get screenName => RouteConstant.search.name;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends BaseStatefulWidgetState<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyQuery(widget.initialQuery));
  }

  @override
  void didUpdateWidget(SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      Future.microtask(() => _applyQuery(widget.initialQuery));
    }
  }

  void _applyQuery(String query) {
    if (!mounted) return;
    if (query.isNotEmpty) {
      ref.read(searchControllerProvider.notifier).updateSearchQuery(query);
    } else {
      ref.read(searchControllerProvider.notifier).reset();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      ref.read(searchControllerProvider.notifier).loadMore();
    }
  }

  String? _getDateRange(ListingModel item) {
    if (item.eventStart == null) return null;
    try {
      final start = DateTime.parse(item.eventStart!).toLocal();
      final startStr =
          '${start.day.toString().padLeft(2, '0')}.${start.month.toString().padLeft(2, '0')}.${start.year}';
      if (item.eventEnd == null) return startStr;
      final end = DateTime.parse(item.eventEnd!).toLocal();
      final endStr =
          '${end.day.toString().padLeft(2, '0')}.${end.month.toString().padLeft(2, '0')}.${end.year}';
      final startTime =
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      final endTime =
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      if (startStr == endStr) return '$startStr $startTime - $endTime';
      return '$startStr - $endStr';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final appBarHeight = (56.0 * textScale.clamp(1.0, 2.0)).h;

    return PopScope(
      onPopInvokedWithResult: (_, __) {
        ref.read(searchControllerProvider.notifier).reset();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: SafeArea(
            child: Container(
              constraints: BoxConstraints(minHeight: 56.h),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.w),
                  Semantics(
                    button: true,
                    label: 'back_button_label'.tr,
                    child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(6.r),
                      child: ExcludeSemantics(
                        child: CommonIcon(
                          icon: Icons.arrow_back_ios,
                          size: 32.r,
                          label: 'back_button_label'.tr,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: CommonText(
                      titleText: 'search'.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textStyle: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _buildBody(state, theme),
      ),
    );
  }

  Widget _buildBody(SearchState state, ThemeData theme) {
    // No query typed yet — show blank
    if (state.searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    if (state.stateConstant == StateConstant.loading && state.items.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.secondary,
        ),
      );
    }

    if (state.stateConstant == StateConstant.error) {
      return Center(
        child: CommonText(
          titleText: 'error_loading'.tr,
          textStyle: theme.textTheme.bodyLarge,
        ),
      );
    }

    if (state.items.isEmpty && state.stateConstant == StateConstant.success) {
      return Center(
        child: CommonText(
          titleText: 'no_data'.tr,
          textStyle: TextStyle(
            fontSize: 14.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(searchControllerProvider.notifier).search(),
      color: theme.colorScheme.secondary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            sliver: SliverList.builder(
              itemCount: state.isPaginationLoading
                  ? state.items.length + 1
                  : state.items.length,
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return Padding(
                    padding: EdgeInsets.all(16.h),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  );
                }
                final item = state.items[index];
                final headerColor = item.categoryTitleBackgroundColor?.hexToColor;
                return ListingCard(
                  imageUrl: item.firstImageUrl ?? '',
                  name: item.title ?? '',
                  address: item.address,
                  todayOpeningStatus: _getDateRange(item),
                  headerColor: headerColor,
                  searchedString: state.searchQuery,
                  showFavourite: false,
                  onTap: () => context.push(
                    '${GoRouterState.of(context).uri}/detail',
                    extra: [item, state.searchQuery],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
