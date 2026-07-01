import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

class ServiceScreenState {
  bool isLoading;
  List<ServiceResponseModel> services;
  int pageNumber;
  bool hasNextPage;

  ServiceScreenState(
    this.isLoading,
    this.services,
    this.pageNumber, {
    this.hasNextPage = true,
  });

  ServiceScreenState copyWith({
    bool? isLoading,
    List<ServiceResponseModel>? services,
    int? pageNumber,
    bool? hasNextPage,
  }) {
    return ServiceScreenState(
      isLoading ?? this.isLoading,
      services ?? this.services,
      pageNumber ?? this.pageNumber,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
