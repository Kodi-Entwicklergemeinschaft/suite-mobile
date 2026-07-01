import 'package:dartz/dartz.dart';
import 'package:template_b/feat/contact/model/request/contact_request_model.dart';
import 'package:template_b/feat/contact/model/response/contact_response_model.dart';

abstract class ContactRepo {
  Future<Either<Exception, ContactResponseModel>> submit(
    ContactRequestModel params,
  );
}
