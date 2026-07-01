import 'package:template_c/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/remove_fav_response_model.dart';
import 'package:template_c/feat/fav/domain/usecase/remove_fav_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final removeFavControllerProvider = Provider(
  (ref) =>
      RemoveFavController(removeFavUseCase: ref.read(removeFavUseCaseProvider)),
);

class RemoveFavController {
  RemoveFavUseCase removeFavUseCase;

  RemoveFavController({required this.removeFavUseCase});
  Future<Either<Exception, RemoveFavResponseModel>> removeFav({
    required RemoveFavRequestModel removeFavRequestModel,
  }) async {
    try {
      final result = await removeFavUseCase.call(removeFavRequestModel);

      return result.fold((l) => Left(l), (r) => Right(r));
    } catch (error) {
      rethrow;
    }
  }
}
