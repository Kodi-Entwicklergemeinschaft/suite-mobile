import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/services/model/response/get_service_config_response_model.dart';
import 'package:template_b/feat/sub_service/presentation/service_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:common_components/src/widgets/common_arrow_back_title_widget.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

class SubServiceScreenParams {
  final String title;
  List<ServiceResponseModel>? services;
  SubServiceScreenParams({required this.title, this.services});
}

class SubServiceScreen extends BaseStatefulWidget {
  final SubServiceScreenParams params;
  const SubServiceScreen({super.key, required this.params});

  @override
  String get screenName => AppRouteConstants.subService.name;

  @override
  ConsumerState<SubServiceScreen> createState() => _SubServiceScreenState();
}

class _SubServiceScreenState extends BaseStatefulWidgetState<SubServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.params.title),
      body: _buildBody(context),
    );
  }

  Widget? _buildBody(BuildContext context) {
    return SafeArea(
      child: Column(children: [22.verticalSpace, _buildGrid(context)]),
    );
  }

  _buildGrid(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: widget.params.services?.length ?? 0,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 24.h,
          childAspectRatio: 164.h / 240.w,
        ),
        itemBuilder: (context, index) {
          final data = widget.params.services![index];
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
    );
  }
}
