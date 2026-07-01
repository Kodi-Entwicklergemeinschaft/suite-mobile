import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/routes/app_routes.dart';

class AuthRequiredNavScreen extends StatelessWidget {
  const AuthRequiredNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonText(
                titleText: 'please_login_to_continue'.tr,
                textAlign: TextAlign.center,
                maxLines: 5,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
              16.verticalSpace,
              AppButton(
                'sign_in'.tr,
                width: 160.w,
                onPressed: () {
                  context.pushNamed(AppRouteConstants.signIn.name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

