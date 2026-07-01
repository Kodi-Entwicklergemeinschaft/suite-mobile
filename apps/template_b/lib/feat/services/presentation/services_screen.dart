import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/feat/common_drawer/app_drawer.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/profile/presentation/widgets/profile_logout_listener.dart';
import 'package:template_b/feat/services/controller/service_screen_controller.dart';
import 'package:template_b/feat/sub_service/presentation/service_card.dart';
import 'package:template_b/feat/home/controller/home_controller.dart';

class ServiceScreen extends BaseStatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  String get screenName => AppRouteConstants.services.name;

  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends BaseStatefulWidgetState<ServiceScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController searchTEC;
  late ScrollController scrollController;
  final _loader = LoadingDialog();

  @override
  void initState() {
    super.initState();
    searchTEC = TextEditingController();
    scrollController = ScrollController();

    // Initial Fetch
    Future.microtask(() {
      final controller = ref.read(serviceScreenProvider.notifier);
      final state = ref.read(serviceScreenProvider);
      controller.getServiceConfig(pageNumer: state.pageNumber);
    });

    // Pagination Listener
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200.h) {
      final controller = ref.read(serviceScreenProvider.notifier);
      final state = ref.watch(serviceScreenProvider);

      // Only trigger if not loading, we have data, and there is a next page
      if (!state.isLoading && state.services.isNotEmpty && state.hasNextPage) {
        controller.getServiceConfig(pageNumer: state.pageNumber);
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeProvider.select((s) => s.localityToggleVersion), (
      previous,
      next,
    ) {
      _loader.show(context);
      ref.read(serviceScreenProvider.notifier).getServiceConfig(pageNumer: 1);
    });

    ref.listen(serviceScreenProvider.select((s) => s.isLoading), (
      previous,
      next,
    ) {
      if (previous == true && next == false) _loader.hide();
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeState = ref.watch(homeProvider);
    final showHamburgerMenu = homeState.config?.hamburgerMenu?.visible ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: LogoutListener(
        child: Scaffold(
          key: scaffoldKey,
          drawer: showHamburgerMenu ? buildAppDrawer(context, ref) : null,
          body: _buildBody(context),
        ),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          42.verticalSpace,
          _buildHeader(context),
          12.verticalSpace,
          CommonText(
            titleText: 'services'.tr,
            isHeader: true,
            textStyle: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          18.verticalSpace,
          _buildGrid(context),
        ],
      ),
    );
  }

  _buildHeader(BuildContext context) {
    final controller = ref.read(serviceScreenProvider.notifier);
    final theme = Theme.of(context);
    final homeState = ref.watch(homeProvider);

    // Check if hamburger menu should be visible from home config
    final showHamburgerMenu = homeState.config?.hamburgerMenu?.visible ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Show hamburger menu only if visible in config
          if (showHamburgerMenu)
            IconButton(
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
              icon: Icon(Icons.menu, size: 32.h.w),
            ),
          8.horizontalSpace,
          Expanded(
            child: SearchBarWidget(
              controller: searchTEC,
              showBorder: true,
              borderColor: theme.colorScheme.inverseSurface.withOpacity(0.5),
              focusColor: theme.colorScheme.inverseSurface.withOpacity(0.6),
              filled: false,
              onChanged: (value) {
                controller.getServiceConfig(pageNumer: 1, searchValue: value);
              },
              onClear: () {
                searchTEC.clear();
                controller.getServiceConfig(pageNumer: 1);
              },
              permanentSuffixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.inverseSurface,
                size: 26.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildGrid(BuildContext context) {
    final serviceState = ref.watch(serviceScreenProvider);
    final controller = ref.read(serviceScreenProvider.notifier);

    // Only show full-screen loader on the first ever load
    if (serviceState.isLoading && serviceState.services.isEmpty) {
      return Expanded(child: Center(child: CommonCircularProgessIndicator()));
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.getServiceConfig(
            pageNumer: 1,
            searchValue: searchTEC.text,
          );
        },
        child: SingleChildScrollView(
          controller: scrollController,
          // AlwaysScrollableScrollPhysics is key for RefreshIndicator to work on empty screens
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: serviceState.services.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: Center(
                    child: CommonText(
                      titleText: 'no_data'.tr,
                      isLiveRegion: true,
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: serviceState.services.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 24.h,
                    childAspectRatio:
                        164.w / 240.h, // Fixed your aspect ratio logic
                  ),
                  itemBuilder: (context, index) {
                    final data = serviceState.services[index];
                    return ServiceCard(
                      titleText: data.label ?? '',
                      imageUrl: data.serviceImage ?? '',
                      onTap: () {
                        final action = data.action!
                          ..tenantServiceId = data.id
                          ..serviceSlug = data.slug
                          ..serviceImage = data.serviceImage;
                        ref
                            .read(templateBHandlerProvider)
                            .executeAction(context, action, title: data.label);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
