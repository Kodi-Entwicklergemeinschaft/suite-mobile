import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';
import 'package:template_b/routes/app_routes.dart';

class DigitalTownhallLocalityScreen extends LocalitySelectionScreen {
  const DigitalTownhallLocalityScreen({super.key});

  @override
  String get screenName => AppRouteConstants.localitySelectionTownHall.name;

  @override
  String get serviceSlug => 'digital-townhall';

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
  ConsumerState<DigitalTownhallLocalityScreen> createState() =>
      _DigitalTownhallLocalityScreenState();
}

class _DigitalTownhallLocalityScreenState
    extends LocalitySelectionScreenState<DigitalTownhallLocalityScreen> {}
