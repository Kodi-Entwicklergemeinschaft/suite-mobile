import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_b/feat/linkhub_service/data/model/linkhub_service_model.dart';

class LinkhubScreen extends StatelessWidget {
  final LinkhubServiceModel service;

  const LinkhubScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return CommonLinkhubScreen(
      title: service.title,
      imageUrl: service.image,
      isAccordion: service.isAccordion,
      groups: service.groups,
      links: service.links,
    );
  }
}
