import 'dart:developer';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:template_b/feat/common_drawer/app_drawer.dart';
import 'package:template_b/feat/home/controller/home_controller.dart';
import 'package:template_b/feat/profile/presentation/widgets/profile_logout_listener.dart';
import 'home_mapper.dart';

class HomeScreen extends BaseStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  String get screenName => AppRouteConstants.home.name;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseStatefulWidgetState<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    log("Home init Called", name: "HomeScreen");
    Future.microtask(
      () => ref.read(homeProvider.notifier).refresh(resetLocality: true),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final config = homeState.config;
    final showHamburgerMenu = config?.hamburgerMenu?.visible ?? false;
    final hasVisibleHeader = config?.header?.visible ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: hasVisibleHeader
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: LogoutListener(
        child: Scaffold(
          key: scaffoldKey,
          drawer: showHamburgerMenu ? buildAppDrawer(context, ref) : null,
          body: SafeArea(
            top: false,
            child: HomeMapper.buildHome(config, scaffoldKey, context, ref),
          ),
        ),
      ),
    );
  }
}
