import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../models/category_filter_model.dart';
import '../service/category_service.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService _service;

  CategoryRepositoryImpl(this._service);

  @override
  Future<Either<Exception, CategoryFilterResponseModel>> getCategoryWithFilters(
    String slugs,
  ) async {
    return _service.getCategoryWithFilters(slugs);
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.watch(categoryServiceProvider)),
);
