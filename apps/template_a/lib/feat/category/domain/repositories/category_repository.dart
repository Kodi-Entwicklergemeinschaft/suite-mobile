import 'package:network/network.dart';
import '../../data/models/category_filter_model.dart';

abstract class CategoryRepository {
  Future<Either<Exception, CategoryFilterResponseModel>> getCategoryWithFilters(
    String slugs,
  );
}
