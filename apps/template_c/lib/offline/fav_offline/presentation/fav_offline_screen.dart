import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:template_c/offline/fav_offline/controller/fav_offline_controller.dart';
import 'package:template_c/offline/fav_offline/presentation/offline_listing_detail_screen.dart';

class FavOfflineScreen extends BaseStatefulWidget {
  const FavOfflineScreen({super.key});

  @override
  String get screenName => 'fav_offline_screen';

  @override
  ConsumerState<FavOfflineScreen> createState() => _FavOfflineScreenState();
}

class _FavOfflineScreenState extends BaseStatefulWidgetState<FavOfflineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(favOfflineControllerProvider.notifier).getOfflineFavList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favOfflineControllerProvider);
    return Scaffold(
      body: Column(
        children: [
          _buildFavAppBarWidget(context),

          if (state.stateConstant == StateConstant.loading)
            Expanded(
              child: Center(
                child: SpinKitFadingCircle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 40.r,
                ),
              ),
            ),

          if (state.stateConstant == StateConstant.success &&
              state.listingModelList.isEmpty)
            Center(
              child: CommonText(
                titleText: 'no_data'.tr,
                textStyle: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (state.stateConstant == StateConstant.success)
            Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildFavAppBarWidget(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topPadding),
        SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonText(
                  titleText: 'events'.tr,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
        16.verticalSpace,
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    final state = ref.watch(favOfflineControllerProvider);
    final controller = ref.watch(favOfflineControllerProvider.notifier);

    return ListView.separated(
      itemBuilder: (context, index) {
        final item = state.listingModelList[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListingItemCard(
            model: item,
            onTap: () {
              final nav = Navigator.of(context);
              nav.push(
                MaterialPageRoute(
                  builder: (_) => OfflineListingDetailScreen(
                    listing: item,
                    onFavTap: item.id != null
                        ? () {
                            controller.removeFavItem(item.id!);
                            nav.pop();
                          }
                        : null,
                  ),
                ),
              );
            },
            onFavoriteTap: item.id != null
                ? () => controller.removeFavItem(item.id!)
                : null,
          ),
        );
      },
      itemCount: state.listingModelList.length,
      separatorBuilder: (BuildContext context, int index) {
        return 16.verticalSpace;
      },
    );
  }
}
