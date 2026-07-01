import 'package:common_components/common_components.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

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
    // image comes from the parent service card, not from action config
    String? image,
    // variant lives at action level (action.variant), not inside config
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

  factory LinkhubServiceModel.fromLocalityChild(LocalityChildService child) {
    final config = child.actionConfig;

    final rawGroups = config['groups'];
    final groups = rawGroups is List
        ? rawGroups
              .map((e) => LinkhubGroupModel.fromJson(e as Map<String, dynamic>))
              .toList()
        : <LinkhubGroupModel>[];

    final rawLinks = config['links'];
    final links = rawLinks is List
        ? rawLinks
              .map((e) => LinkhubLinkModel.fromJson(e as Map<String, dynamic>))
              .toList()
        : <LinkhubLinkModel>[];

    return LinkhubServiceModel(
      id: child.id,
      title: child.title,
      image: child.image,
      variant: child.actionVariant,
      groups: groups,
      links: links,
    );
  }
}
