import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';
import 'package:template_b/routes/app_routes.dart';

class DefectReporterLocalityScreen extends LocalitySelectionScreen {
  const DefectReporterLocalityScreen({super.key});

  @override
  String get screenName => AppRouteConstants.locationSelectionDefectReport.name;

  @override
  String get serviceSlug => 'defect-reporter';

  @override
  void onConfirmed(
    BuildContext context,
    WidgetRef ref,
    LocalityDeliveryModel delivery,
    LocalityModel selectedLocation,
  ) {
    final child = delivery.firstService;
    if (child == null) return;
    ref
        .read(templateBHandlerProvider)
        .executeAction(
          context,
          ActionResponseModel.fromLocalityChild(
            child,
            localityId: selectedLocation.id,
          ),
          title: child.title,
        );
  }

  @override
  ConsumerState<DefectReporterLocalityScreen> createState() =>
      _DefectReporterLocalityScreenState();
}

class _DefectReporterLocalityScreenState
    extends LocalitySelectionScreenState<DefectReporterLocalityScreen> {}
