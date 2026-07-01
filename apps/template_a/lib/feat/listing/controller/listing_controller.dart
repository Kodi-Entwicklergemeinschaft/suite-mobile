import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/state_constant.dart';
import '../data/models/listing_filter_model.dart';
import '../domain/usecases/get_listings_usecase.dart';
import '../state/listing_state.dart';

final listingControllerProvider =
    NotifierProvider.family<ListingController, ListingState, String>(
      (familyKey) => ListingController(familyKey),
    );

class ListingController extends Notifier<ListingState> {
  final String familyKey;
  ListingController(this.familyKey);

  GetListingsUseCase get _useCase => ref.read(getListingsUseCaseProvider);

  @override
  ListingState build() {
    return ListingState(
      StateConstant.loading,
      [],
      '',
      ListingFilterModel(limit: 10),
    );
  }

  Future<void> getListing(ListingFilterModel filter) async {
    state = state.copyWith(stateConstant: StateConstant.loading, filter: filter);

    try {
      final result = await _useCase.call(filter);
      if (!ref.mounted) return;
      result.fold(
        (error) {
          state = state.copyWith(
            stateConstant: StateConstant.error,
            message: error.toString(),
          );
        },
        (response) {
          state = state.copyWith(
            stateConstant: StateConstant.success,
            listingModel: response.items ?? [],
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        message: e.toString(),
      );
    }
  }

  void updateList(String id, bool isFav) {
    final updated = state.listingModel.map((item) {
      return item.id == id ? item.copyWith(isFavourite: isFav) : item;
    }).toList();
    state = state.copyWith(listingModel: updated);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    try {
      final result = await _useCase.call(state.filter);
      if (!ref.mounted) return;
      result.fold(
        (error) => state = state.copyWith(
          stateConstant: StateConstant.error,
          isRefreshing: false,
        ),
        (response) => state = state.copyWith(
          stateConstant: StateConstant.success,
          listingModel: response.items ?? [],
          isRefreshing: false,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
          stateConstant: StateConstant.error, isRefreshing: false);
    }
  }
}
