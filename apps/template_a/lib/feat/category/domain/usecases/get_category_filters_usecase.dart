import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../../data/models/category_filter_model.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../repositories/category_repository.dart';

class GetCategoryFiltersUseCase {
  final CategoryRepository _repository;

  GetCategoryFiltersUseCase(this._repository);

  Future<Either<Exception, CategoryFilterResponseModel>> call(String slugs) {
    return _repository.getCategoryWithFilters(slugs);
  }
}

final getCategoryFiltersUseCaseProvider = Provider<GetCategoryFiltersUseCase>(
  (ref) => GetCategoryFiltersUseCase(ref.watch(categoryRepositoryProvider)),
);
