import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_b/feat/upload_ad/presentation/upload_ad_image_card.dart';

class UploadAdScreen extends BaseStatefulWidget {
  const UploadAdScreen({super.key});

  @override
  String get screenName => AppRouteConstants.uploadAd.name;

  @override
  ConsumerState<UploadAdScreen> createState() => _UploadAdScreenState();
}

class _UploadAdScreenState extends BaseStatefulWidgetState<UploadAdScreen> {
  TextEditingController linkTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'upload_ad'.tr),
      body: _buildBody(context),
    );
  }

  Widget? _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  29.verticalSpace,
                  CommonFloatingLabelDropDown(
                    label: 'add_package'.tr,
                    hintText: 'select_package'.tr,
                    items: [],
                    onChanged: (value) {},
                  ),
                  22.verticalSpace,
                  UploadAdImageCard(label: 'upload_ad_image'.tr),
                  22.verticalSpace,
                  CommonTextField(
                    controller: linkTEC,
                    label: 'link'.tr,
                    hintText: 'enter_link'.tr,
                    filled: false,
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: AppButton('confirm'.tr, onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
