import 'package:dartz/dartz.dart';
import 'package:template_b/feat/contact/data/service/contact_service.dart';
import 'package:template_b/feat/contact/domain/repo/contact_repo.dart';
import 'package:template_b/feat/contact/model/request/contact_request_model.dart';
import 'package:template_b/feat/contact/model/response/contact_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactRepoImplProvider = Provider(
  (ref) => ContactRepoImpl(contactService: ref.read(contactServiceProvider)),
);

class ContactRepoImpl implements ContactRepo {
  ContactService contactService;

  ContactRepoImpl({required this.contactService});

  @override
  Future<Either<Exception, ContactResponseModel>> submit(
    ContactRequestModel params,
  ) async {
    final res = await contactService.submit(params);
    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
