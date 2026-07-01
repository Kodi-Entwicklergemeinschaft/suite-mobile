import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/parking/controller/parking_controller.dart';
import 'package:template_a/feat/parking/data/models/parking_spot_model.dart';
import 'package:template_a/router/route_constant.dart';

// geo: URI opens the native maps app on both Android and iOS
Uri _mapsUri(double lat, double lng, String label) =>
    Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');

class ParkingScreen extends BaseStatefulWidget {
  const ParkingScreen({super.key});

  @override
  String get screenName => RouteConstant.parking.name;

  @override
  ConsumerState<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends BaseStatefulWidgetState<ParkingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parkingControllerProvider.notifier).loadParkingSpaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;
    final state = ref.watch(parkingControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE7F1F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F1F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (state.spotsState) {
        StateConstant.loading => const Center(
            child: CircularProgressIndicator(),
          ),
        StateConstant.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  titleText: 'Failed to load parking data',
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16.h),
                OutlinedButton(
                  onPressed: () => ref
                      .read(parkingControllerProvider.notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        StateConstant.success => RefreshIndicator(
            onRefresh: () =>
                ref.read(parkingControllerProvider.notifier).refresh(),
            color: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primary,
            child: state.spots.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: CommonText(
                            titleText: 'No parking spaces available',
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: state.spots.length,
                    itemBuilder: (context, index) {
                      final spot = state.spots[index];
                      final isLast = index == state.spots.length - 1;
                      return _ParkingSpotCard(
                        spot: spot,
                        teal: teal,
                        topPadding: index == 0 ? 0 : 12.h,
                        showDivider: !isLast,
                        title: index == 0 ? 'Parking' : null,
                        onOpenMaps: () => ref
                            .read(launcherHandler)
                            .launch(_mapsUri(spot.lat, spot.lng, spot.name)),
                      );
                    },
                  ),
          ),
      },
    );
  }
}

class _ParkingSpotCard extends StatelessWidget {
  final ParkingSpotModel spot;
  final Color teal;
  final double topPadding;
  final bool showDivider;
  final String? title;
  final VoidCallback onOpenMaps;

  const _ParkingSpotCard({
    required this.spot,
    required this.teal,
    required this.topPadding,
    required this.showDivider,
    required this.onOpenMaps,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final freeFraction =
        spot.totalSlots > 0 ? spot.availableSlots / spot.totalSlots : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Center(
            child: CommonText(
              titleText: title!,
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        SizedBox(height: topPadding),

        Center(
          child: CommonText(
            titleText: spot.name,
            textStyle: TextStyle(
              color: teal,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: 12.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              titleText: 'Free',
              textStyle: TextStyle(fontSize: 18.sp, color: Colors.black87),
            ),
            CommonText(
              titleText: '${spot.availableSlots}',
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E9B4E),
              ),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              titleText: 'Total :',
              textStyle: TextStyle(fontSize: 18.sp, color: Colors.black87),
            ),
            CommonText(
              titleText: '${spot.totalSlots}',
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return ClipRRect(
              borderRadius: BorderRadius.circular(25.r),
              child: SizedBox(
                height: 14.h,
                width: w,
                child: Stack(
                  children: [
                    Container(color: Colors.red[400]),
                    if (freeFraction > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: w * freeFraction,
                          child: Container(color: const Color(0xFF2E9B4E)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 14.h),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onOpenMaps,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: teal, width: 1.5),
              shape: const StadiumBorder(),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              backgroundColor: Colors.transparent,
            ),
            child: CommonText(
              titleText: 'Open Maps',
              textStyle: TextStyle(
                color: teal,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: 14.h),

        if (showDivider) Divider(color: teal, thickness: 1),
      ],
    );
  }
}
