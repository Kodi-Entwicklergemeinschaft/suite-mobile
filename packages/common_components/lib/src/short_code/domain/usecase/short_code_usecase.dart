import 'package:network/network.dart';
import 'package:common_components/src/short_code/data/repo_impl/short_code_repo_impl.dart';
import 'package:common_components/src/short_code/domain/repository/short_code_repo.dart';
import 'package:common_components/src/short_code/model/request/short_code_request_model.dart';
import 'package:common_components/src/short_code/model/response/short_code_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shortCodeUseCaseProvider = Provider<ShortCodeUsecase>(
  (ref) => ShortCodeUsecase(ref.read(shortCodeRepoProvider)),
);

class ShortCodeUsecase
    implements BaseUseCase<ShortCodeResponseModel, ShortCodeRequestModel> {
  ShortCodeRepo shortCodeRepo;

  ShortCodeUsecase(this.shortCodeRepo);

  @override
  Future<Either<Exception, ShortCodeResponseModel>> call(
    ShortCodeRequestModel params,
  ) async {
    final res = await shortCodeRepo.getShortCode(params);

    return res.fold((l) => Left(l), (r) => Right(r));
  }
}
