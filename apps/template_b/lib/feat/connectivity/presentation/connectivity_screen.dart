import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';

class ConnectivityScreen extends BaseStatefulWidget {
  const ConnectivityScreen({super.key});

  @override
  String get screenName => 'connectivity_screen';

  @override
  ConsumerState<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState
    extends BaseStatefulWidgetState<ConnectivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeSemantics(child: Icon(Icons.wifi_off, size: 100.sp)),

            CommonText(
              titleText: 'no_internet'.tr,
              isLiveRegion: true,
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
