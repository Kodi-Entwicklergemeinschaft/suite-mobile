import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/feat/listing/controller/listing_screen_controller.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/listing/params/listing_screen_params.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:theme/theme.dart';

class ListingScreen extends BaseStatefulWidget {
  final ListingScreenParams params;

  const ListingScreen({super.key, required this.params});

  @override
  String get screenName => RouteConstant.listing.name;

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends BaseStatefulWidgetState<ListingScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(listingScreenControllerProvider(widget.params.familyKey).notifier)
          .getListing(widget.params.initialFilter);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) {
      ref
          .read(listingScreenControllerProvider(widget.params.familyKey).notifier)
          .loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      listingScreenControllerProvider(widget.params.familyKey),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'back_button_label'.tr,
          child: InkWell(
            onTap: () => context.pop(),
            child: ExcludeSemantics(
              child: CommonIcon(
                icon: Icons.arrow_back_ios,
                size: 24.w,
                label: widget.params.screenTitle,
              ),
            ),
          ),
        ),
        title: CommonText(
          titleText: widget.params.screenTitle.isNotEmpty
              ? widget.params.screenTitle
              : 'listingTitle'.tr,
          textStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(listingScreenControllerProvider(widget.params.familyKey).notifier)
            .refresh(),
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.primary,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(state) {
    if (state.stateConstant == StateConstant.loading && state.items.isEmpty) {
      return ShimmerWidget(
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          itemCount: 6,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, __) => Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      );
    }

    if (state.stateConstant == StateConstant.error && state.items.isEmpty) {
      return Center(
        child: CommonText(
          titleText: 'error_loading'.tr,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: CommonText(
          titleText: 'no_data'.tr,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return ShimmerWidget(
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
        return _ListingListItem(item: state.items[index]);
      },
    );
  }
}

class _ListingListItem extends StatelessWidget {
  final ListingModel item;
  const _ListingListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticLabel = [item.title, item.summary]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
      onTap: () => context.push(
        '${GoRouterState.of(context).uri}/detail',
        extra: item,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 120.h,
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              SizedBox(
                width: 120.w,
                child: CommonImage(
                  imagePath: item.firstImageUrl ?? '',
                  fit: BoxFit.cover,
                  height: 120.h,
                  width: 120.w,
                  errorWidget: item.categoryFallbackImage?.isNotEmpty == true
                      ? (context, error, stack) => CommonImage(
                            imagePath: item.categoryFallbackImage!,
                            fit: BoxFit.cover,
                            height: 120.h,
                            width: 120.w,
                          )
                      : null,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonText(
                        titleText: item.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).extension<AppTextColors>()!.inverse,
                        ),
                      ),
                      if (item.summary != null && item.summary!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        CommonText(
                          titleText: item.summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).extension<AppTextColors>()!.inverse.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
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
