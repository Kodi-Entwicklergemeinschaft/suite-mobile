import 'package:flutter/material.dart';
import 'package:locale/locale.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:common_components/common_components.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/legal/constant/legal_type.dart';
import 'package:template_b/feat/legal/controller/legal_controller.dart';
import 'package:template_b/feat/legal/model/response/legal_response_model.dart';
import '../widgets/menu_item_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LegalScreen extends BaseStatefulWidget {
  const LegalScreen({super.key});

  @override
  String get screenName => AppRouteConstants.legal.name;

  @override
  ConsumerState<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends BaseStatefulWidgetState<LegalScreen> {
  @override
  void initState() {
    Future.microtask(() {
      final controller = ref.read(legalControllerProvider.notifier);

      controller.getLegal(
        legalType: LegalType.imprint,
        onError: (message) {
          AppSnackBar.showError(context, message);
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(legalControllerProvider.notifier);
    final state = ref.watch(legalControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(title: 'legal'.tr),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                MenuItemWidget(
                  title: 'imprint'.tr,
                  onTap: () async {
                    _executeAction(LegalType.imprint, 'imprint'.tr);
                  },
                ),
                MenuItemWidget(
                  title: 'privacy_policy'.tr,
                  onTap: () async {
                    _executeAction(
                      LegalType.privacyPolicy,
                      'privacy_policy'.tr,
                    );
                  },
                ),
                MenuItemWidget(
                  title: 'terms_of_use'.tr,
                  onTap: () async {
                    _executeAction(LegalType.termsOfUse, 'terms_of_use'.tr);
                  },
                ),
              ],
            ),
          ),
          if (state.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: CommonCircularProgessIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  _executeAction(LegalType legalType, String title) {
    final state = ref.watch(legalControllerProvider);

    final legalData = state.legalResponseModel?.data?.firstWhere(
      (element) => element.key == legalType.name,
    );
    if (legalData?.action != null) {
      ref
          .read(templateBHandlerProvider)
          .executeAction(context, legalData!.action!, title: title);
    }
  }
}
