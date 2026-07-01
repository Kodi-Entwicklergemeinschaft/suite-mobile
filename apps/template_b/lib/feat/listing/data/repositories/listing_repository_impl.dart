import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../models/listing_filter_model.dart';
import '../models/listing_model.dart';
import '../models/listing_response_model.dart';
import '../models/listing_filter_config_response_model.dart';
import '../../domain/repositories/listing_repository.dart';

/// Implementation of ListingRepository using API calls
class ListingRepositoryImpl implements ListingRepository {
  final ApiHelper _apiHelper;

  ListingRepositoryImpl(this._apiHelper);

  bool get _isLiveMode {
    final value = dotenv.maybeGet('BASE_URL') ?? '';
    return value.isNotEmpty && !value.startsWith('YOUR_');
  }

  @override
  Future<Either<Exception, ListingResponseModel>> getListings(
    ListingFilterModel filter,
  ) async {
    if (!_isLiveMode) {
      return _getListingsFromAsset(filter);
    }
    final result = await _apiHelper.getRequest<ListingResponseModel>(
      path: '/api/listings',
      params: filter.toQueryParams(),
      create: () => ListingResponseModel(),
    );
    return result.fold((error) => Left(error), (response) => Right(response));
  }

  Future<Either<Exception, ListingResponseModel>> _getListingsFromAsset(
    ListingFilterModel filter,
  ) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/config/news.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final response = ListingResponseModel().fromJson(data);
      return Right(response);
    } catch (e) {
      return Left(Exception('Failed to load listings from asset: $e'));
    }
  }

  @override
  Future<Either<Exception, ListingModel>> getListingById(
    String listingId,
  ) async {
    if (!_isLiveMode) {
      return _getListingDetailFromAsset();
    }
    final result = await _apiHelper.getRequest<ListingModel>(
      path: '/api/listings/$listingId',
      create: () => ListingModel(),
    );
    return result.fold((error) => Left(error), (listing) => Right(listing));
  }

  @override
  Future<Either<Exception, ListingModel>> getListingBySlug(String slug) async {
    if (!_isLiveMode) {
      return _getListingDetailFromAsset();
    }
    final result = await _apiHelper.getRequest<ListingModel>(
      path: '/api/listings/slug/$slug',
      create: () => ListingModel(),
    );
    return result.fold((error) => Left(error), (listing) => Right(listing));
  }

  Future<Either<Exception, ListingModel>> _getListingDetailFromAsset() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/config/news_detail.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final model = ListingModel().fromJson(data);
      return Right(model);
    } catch (e) {
      return Left(Exception('Failed to load listing detail from asset: $e'));
    }
  }

  @override
  Future<Either<Exception, ListingFilterConfigResponseModel>> getFilterConfig(
    String categorySlug,
  ) async {
    final result = await _apiHelper
        .getRequest<ListingFilterConfigResponseModel>(
          path: '/api/listings/filters/$categorySlug',
          create: () => ListingFilterConfigResponseModel(),
        );
    return result.fold((error) => Left(error), (config) => Right(config));
  }
}

/// Provider for ListingRepository
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ListingRepositoryImpl(apiHelper);
});
