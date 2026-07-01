import 'package:network/network.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:template_b/core/constants/api_endpoints.dart';
import 'package:template_b/feat/contact/model/request/contact_request_model.dart';
import 'package:template_b/feat/contact/model/response/contact_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactServiceProvider = Provider(
  (ref) => ContactService(apiHelper: ref.read(apiHelperProvider)),
);

class ContactService {
  ApiHelper apiHelper;

  ContactService({required this.apiHelper});

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<Either<Exception, ContactResponseModel>> submit(
    ContactRequestModel params,
  ) async {
    if (!_isLiveMode) return Right(ContactResponseModel());
    final result = await apiHelper.postRequest(
      path: ApiEndpoints.contactUsConfig,
      create: () => ContactResponseModel(),
      body: params.toJson(),
    );
    return result.fold(
      (failure) => Left(failure),
      (response) => Right(response),
    );
  }
}
