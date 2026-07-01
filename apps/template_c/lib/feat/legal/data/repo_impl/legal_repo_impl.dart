import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/legal/data/service/legal_service.dart';
import 'package:template_c/feat/legal/domain/repo/legal_repo.dart';
import 'package:template_c/feat/legal/model/request/legal_request_model.dart';
import 'package:template_c/feat/legal/model/response/legal_response_model.dart';

final legalRepoImplProvider = Provider<LegalRepoImpl>((ref) {
  return LegalRepoImpl(legalService: ref.read(legalServiceProvider));
});

class LegalRepoImpl implements LegalRepo {
  final LegalService _legalService;

  LegalRepoImpl({required LegalService legalService})
    : _legalService = legalService;

  @override
  Future<Either<Exception, LegalResponseModel>> getLegalConfig(
    LegalRequestModel params,
  ) async {
    final result = await _legalService.getLegalConfig(params);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
