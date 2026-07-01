import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/feat/dashbboard/controller/dashboard_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_b/feat/dashbboard/presentation/dashboard_card.dart';

class DashboardScreen extends BaseStatefulWidget {
  const DashboardScreen({super.key});

  @override
  String get screenName => AppRouteConstants.dashboardScreen.name;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends BaseStatefulWidgetState<DashboardScreen> {
  @override
  void initState() {
    Future.microtask(() {
      ref.read(dashboardControllerProvider.notifier).getDashboardConfig();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(title: 'dashboard'.tr),
      body: (state.isLoading)
          ? CommonCircularProgessIndicator()
          : _buildBody(context),
    );
  }

  Widget? _buildBody(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    if (state.serviceResponseModelList.isEmpty) {
      return Center(child: Text('no_data'.tr));
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.getDashboardConfig();
        },
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          itemCount: state.serviceResponseModelList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            mainAxisExtent: 164.h,
            childAspectRatio: 164.h / 164.w,
          ),
          itemBuilder: (context, index) {
            final item = state.serviceResponseModelList[index];

            return DashboardCard(serviceResponseModel: item);
          },
        ),
      ),
    );
  }
}
