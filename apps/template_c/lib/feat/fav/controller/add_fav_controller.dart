import 'package:template_c/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/add_fav_response_model.dart';
import 'package:template_c/feat/fav/domain/usecase/add_fav_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

final addFavControllerProvider = Provider(
  (ref) => AddFavController(addFavUseCase: ref.read(addFavUseCaseProvider)),
);

class AddFavController {
  AddFavUseCase addFavUseCase;
  AddFavController({required this.addFavUseCase});

  Future<Either<Exception, AddFavResponseModel>> addFav({
    required AddFavRequestModel addFavRequestModel,
  }) async {
    try {
      final result = await addFavUseCase.call(addFavRequestModel);
      return result.fold((l) => Left(l), (r) => Right(r));
    } catch (error) {
      rethrow;
    }
  }
}
