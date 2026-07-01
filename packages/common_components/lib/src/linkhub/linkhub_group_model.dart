import 'package:common_components/src/linkhub/linkhub_link_model.dart';

class LinkhubGroupModel {
  final String title;
  final String? image;
  final List<LinkhubLinkModel> links;

  const LinkhubGroupModel({
    required this.title,
    this.image,
    required this.links,
  });

  factory LinkhubGroupModel.fromJson(Map<String, dynamic> json) {
    final rawLinks = json['links'];
    final links = rawLinks is List
        ? rawLinks
            .map((e) => LinkhubLinkModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <LinkhubLinkModel>[];
    return LinkhubGroupModel(
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString(),
      links: links,
    );
  }
}
