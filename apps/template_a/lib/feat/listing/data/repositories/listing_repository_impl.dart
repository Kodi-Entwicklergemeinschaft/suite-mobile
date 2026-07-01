import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import '../models/listing_filter_model.dart';
import '../models/listing_model.dart';
import '../models/listing_response_model.dart';
import '../../domain/repositories/listing_repository.dart';

class ListingRepositoryImpl implements ListingRepository {
  final ApiHelper _apiHelper;

  ListingRepositoryImpl(this._apiHelper);

  @override
  Future<Either<Exception, ListingResponseModel>> getListings(
    ListingFilterModel filter,
  ) async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/listings.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        return Right(ListingResponseModel().fromJson(data));
      } catch (e) {
        return Left(Exception('Failed to load local listings: $e'));
      }
    }
    final result = await _apiHelper.getRequest<ListingResponseModel>(
      path: ApiEndpoints.listings,
      params: filter.toQueryParams(),
      create: () => ListingResponseModel(),
    );
    return result.fold((e) => Left(e), (r) => Right(r));
  }

  @override
  Future<Either<Exception, ListingModel>> getListingById(
    String listingId, {
    String? categorySlug,
  }) async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/listings.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final response = ListingResponseModel().fromJson(data);
        final match = response.items?.firstWhere(
          (l) => l.id == listingId,
          orElse: () => response.items?.first ?? ListingModel(),
        );
        return Right(match ?? ListingModel());
      } catch (e) {
        return Left(Exception('Listing not found in local data'));
      }
    }
    final params = <String, dynamic>{};
    if (categorySlug != null && categorySlug.isNotEmpty) {
      params['categorySlug'] = categorySlug;
    }
    final result = await _apiHelper.getRequest<ListingModel>(
      path: '${ApiEndpoints.listings}/$listingId',
      params: params.isEmpty ? null : params,
      create: () => ListingModel(),
    );
    return result.fold((e) => Left(e), (r) => Right(r));
  }

  @override
  Future<Either<Exception, ListingModel>> getListingBySlug(String slug) async {
    if (!isLiveMode) {
      try {
        final jsonStr = await rootBundle.loadString('assets/config/listings.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final response = ListingResponseModel().fromJson(data);
        final match = response.items?.firstWhere(
          (l) => l.slug == slug,
          orElse: () => response.items?.first ?? ListingModel(),
        );
        return Right(match ?? ListingModel());
      } catch (e) {
        return Left(Exception('Listing not found in local data'));
      }
    }
    final result = await _apiHelper.getRequest<ListingModel>(
      path: '${ApiEndpoints.listings}/slug/$slug',
      create: () => ListingModel(),
    );
    return result.fold((e) => Left(e), (r) => Right(r));
  }
}

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepositoryImpl(ref.watch(apiHelperProvider));
});
