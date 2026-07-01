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

class ListingRepositoryImpl implements ListingRepository {
  final ApiHelper _apiHelper;

  ListingRepositoryImpl(this._apiHelper);

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  String _localAssetForFilter(ListingFilterModel filter) {
    if (filter.search != null && filter.search!.isNotEmpty) {
      return 'assets/config/listings_search.json';
    }
    final sub = filter.subcategorySlug;
    if (sub == 'musik') return 'assets/config/listings_musik.json';
    if (sub == 'kultur') {
      final sortBy = filter.extraParams['sortBy']?.toString();
      if (sortBy == 'createdAt') return 'assets/config/listings_kultur_created.json';
      return 'assets/config/listings_kultur.json';
    }
    return 'assets/config/listings.json';
  }

  ListingModel _stripImages(ListingModel item) =>
      item.copyWith(heroImageUrl: '', categoryFallbackImage: '');

  ListingResponseModel _stripResponseImages(ListingResponseModel resp) =>
      resp.copyWith(items: resp.items?.map(_stripImages).toList());

  Future<List<ListingModel>> _allLocalItems() async {
    final assets = [
      'assets/config/listings.json',
      'assets/config/listings_musik.json',
      'assets/config/listings_kultur.json',
      'assets/config/listings_kultur_created.json',
      'assets/config/listings_search.json',
    ];
    final items = <ListingModel>[];
    final seen = <String>{};
    for (final asset in assets) {
      final jsonStr = await rootBundle.loadString(asset);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['data']?['items'] as List?) ?? [];
      for (final e in list) {
        final item = _stripImages(
          ListingModel().fromJson(e as Map<String, dynamic>),
        );
        if (item.id != null && seen.add(item.id!)) items.add(item);
      }
    }
    return items;
  }

  @override
  Future<Either<Exception, ListingResponseModel>> getListings(
    ListingFilterModel filter,
  ) async {
    if (!_isLiveMode) {
      final asset = _localAssetForFilter(filter);
      final jsonStr = await rootBundle.loadString(asset);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      return Right(_stripResponseImages(ListingResponseModel().fromJson(data)));
    }
    final result = await _apiHelper.getRequest<ListingResponseModel>(
      path: '/api/listings',
      params: filter.toQueryParams(),
      create: () => ListingResponseModel(),
    );
    return result.fold((error) => Left(error), (response) => Right(response));
  }

  @override
  Future<Either<Exception, ListingModel>> getListingById(
    String listingId,
  ) async {
    if (!_isLiveMode) {
      final items = await _allLocalItems();
      final found = items.firstWhere(
        (l) => l.id == listingId,
        orElse: () => items.isNotEmpty ? items.first : ListingModel(),
      );
      return Right(found);
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
      final items = await _allLocalItems();
      final found = items.firstWhere(
        (l) => l.slug == slug,
        orElse: () => items.isNotEmpty ? items.first : ListingModel(),
      );
      return Right(found);
    }
    final result = await _apiHelper.getRequest<ListingModel>(
      path: '/api/listings/slug/$slug',
      create: () => ListingModel(),
    );
    return result.fold((error) => Left(error), (listing) => Right(listing));
  }

  @override
  Future<Either<Exception, ListingFilterConfigResponseModel>> getFilterConfig(
    String categorySlug,
  ) async {
    if (!_isLiveMode) {
      return Right(ListingFilterConfigResponseModel());
    }
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
