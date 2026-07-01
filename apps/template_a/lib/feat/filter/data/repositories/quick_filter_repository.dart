import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import '../models/quick_filter_response_model.dart';

abstract class QuickFilterRepository {
  Future<Either<Exception, QuickFilterResponseModel>> getQuickFilters(
    String categorySlug,
  );
}

class QuickFilterRepositoryImpl implements QuickFilterRepository {
  final ApiHelper _apiHelper;

  QuickFilterRepositoryImpl(this._apiHelper);

  @override
  Future<Either<Exception, QuickFilterResponseModel>> getQuickFilters(
    String categorySlug,
  ) async {
    if (!isLiveMode) {
      return Right(QuickFilterResponseModel(success: true, groups: []));
    }
    final result = await _apiHelper.getRequest<QuickFilterResponseModel>(
      path: '${ApiEndpoints.categories}/$categorySlug/quick-filters',
      create: () => QuickFilterResponseModel(),
    );
    return result.fold((e) => Left(e), (r) => Right(r));
  }
}

final quickFilterRepositoryProvider = Provider<QuickFilterRepository>(
  (ref) => QuickFilterRepositoryImpl(ref.watch(apiHelperProvider)),
);
