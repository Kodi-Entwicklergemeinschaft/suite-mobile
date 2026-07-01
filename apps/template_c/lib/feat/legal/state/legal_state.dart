import 'package:template_c/feat/legal/model/response/legal_response_model.dart';

class LegalState {
  LegalResponseModel? legalResponseModel;
  bool isLoading;

  LegalState(this.legalResponseModel,this.isLoading);

  LegalState copyWith({LegalResponseModel? legalResponseModel, bool? isLoading}) {
    return LegalState(legalResponseModel ?? this.legalResponseModel, isLoading ?? this.isLoading);
  }
}
