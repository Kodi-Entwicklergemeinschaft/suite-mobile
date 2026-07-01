import 'package:network/network.dart';
import 'package:template_b/feat/legal/constant/legal_type.dart';

class LegalRequestModel implements BaseModel<LegalRequestModel> {
  final LegalType legalType;

  LegalRequestModel({required this.legalType});

  @override
  LegalRequestModel fromJson(Map<String, dynamic> json) {
    final typeName = json['legalType'] as String? ?? json['legal_type'] as String?;
    return LegalRequestModel(
      legalType: LegalType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => LegalType.privacyPolicy,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'legalType': legalType.name};
  }
}
