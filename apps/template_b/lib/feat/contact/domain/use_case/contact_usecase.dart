import 'package:flutter/material.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/contact/data/repo_impl/contact_repo_impl.dart';
import 'package:template_b/feat/contact/domain/repo/contact_repo.dart';
import 'package:template_b/feat/contact/model/request/contact_request_model.dart';
import 'package:template_b/feat/contact/model/response/contact_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactUseCaseProvider = Provider(
  (ref) => ContactUsecase(contactRepo: ref.read(contactRepoImplProvider)),
);

class ContactUsecase
    implements BaseUseCase<ContactResponseModel, ContactRequestModel> {
  ContactRepo contactRepo;

  ContactUsecase({required this.contactRepo});

  @override
  Future<Either<Exception, ContactResponseModel>> call(
    ContactRequestModel params,
  ) async {
    final res = await contactRepo.submit(params);

    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
