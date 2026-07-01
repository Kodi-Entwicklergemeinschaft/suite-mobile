import 'package:flutter/material.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/handler/template_c_handler.dart';
import 'package:template_c/feat/legal/constant/legal_type.dart';
import 'package:template_c/feat/legal/controller/legal_controller.dart';
import 'package:template_c/feat/legal/model/response/legal_response_model.dart';
import 'package:template_c/feat/profile/presentation/widgets/menu_item_widget.dart';
import 'package:template_c/router/route_constant.dart';

class LegalScreen extends BaseStatefulWidget {
  const LegalScreen({super.key});

  @override
  String get screenName => RouteConstant.legal.name;

  @override
  ConsumerState<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends BaseStatefulWidgetState<LegalScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(legalControllerProvider.notifier);
    final state = ref.watch(legalControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'legal'.tr,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
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
    final state = ref.read(legalControllerProvider);

    final legalData = state.legalResponseModel?.data?.firstWhere(
      (element) => element.key == legalType.name,
      orElse: () => LegalData(),
    );
    if (legalData?.action != null) {
      ref
          .read(templateCHandlerProvider)
          .executeAction(context, legalData!.action!, title: title);
    }
  }
}
