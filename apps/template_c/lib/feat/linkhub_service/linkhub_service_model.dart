import 'package:common_components/common_components.dart';
import 'package:template_c/core/model/action_response_model.dart';

class LinkhubServiceModel {
  final String id;
  final String title;
  final String? image;
  final String variant;
  final List<LinkhubGroupModel> groups;
  final List<LinkhubLinkModel> links;

  const LinkhubServiceModel({
    required this.id,
    required this.title,
    this.image,
    required this.variant,
    required this.groups,
    required this.links,
  });

  bool get isAccordion => variant == 'accordion';

  factory LinkhubServiceModel.fromAction({
    required String id,
    required String title,
    String? image,
    String? variant,
    ConfigResponseModel? config,
  }) {
    return LinkhubServiceModel(
      id: id,
      title: title,
      image: image,
      variant: variant ?? 'list',
      groups: config?.groups ?? [],
      links: config?.links ?? [],
    );
  }
}
