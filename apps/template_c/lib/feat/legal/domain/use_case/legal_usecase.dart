import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/legal/data/repo_impl/legal_repo_impl.dart';
import 'package:template_c/feat/legal/domain/repo/legal_repo.dart';
import 'package:template_c/feat/legal/model/request/legal_request_model.dart';
import 'package:template_c/feat/legal/model/response/legal_response_model.dart';

final legalUsecaseProvider = Provider<LegalUsecase>((ref) {
  return LegalUsecase(legalRepo: ref.read(legalRepoImplProvider));
});

class LegalUsecase implements BaseUseCase<LegalResponseModel, LegalRequestModel> {
  final LegalRepo _legalRepo;

  LegalUsecase({required LegalRepo legalRepo}) : _legalRepo = legalRepo;

  @override
  Future<Either<Exception, LegalResponseModel>> call(
    LegalRequestModel params,
  ) async {
    final result = await _legalRepo.getLegalConfig(params);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
