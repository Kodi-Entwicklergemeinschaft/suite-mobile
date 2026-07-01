import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/organizer/controller/organizer_follow_toggle_controller.dart';
import 'package:template_c/feat/organizer/domain/usecases/get_organizer_recommendations_usecase.dart';
import 'package:template_c/feat/organizer/domain/usecases/get_organizers_usecase.dart';
import 'package:template_c/feat/organizer/state/organizer_list_state.dart';

final organizerListControllerProvider =
    NotifierProvider<OrganizerListController, OrganizerListState>(
  OrganizerListController.new,
);

class OrganizerListController extends Notifier<OrganizerListState> {
  GetOrganizersUseCase get _useCase => ref.read(getOrganizersUseCaseProvider);
  GetOrganizerRecommendationsUseCase get _recommendationsUseCase =>
      ref.read(getOrganizerRecommendationsUseCaseProvider);

  @override
  OrganizerListState build() =>
      OrganizerListState(StateConstant.loading, [], '');

  Future<void> fetchOrganizers() => _fetchPage(1, replace: true);

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    if (state.stateConstant == StateConstant.loading) return;
    await _fetchPage(state.currentPage + 1, replace: false);
  }

  Future<void> _fetchPage(int page, {required bool replace}) async {
    if (replace) {
      state = state.copyWith(
        stateConstant: StateConstant.loading,
        organizers: [],
        currentPage: 0,
        hasMore: false,
      );
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final result = await _useCase.call(const NoParams(), page: page, limit: 20);
    if (!ref.mounted) return;
    result.fold(
      (error) => state = state.copyWith(
        stateConstant: StateConstant.error,
        isLoadingMore: false,
        message: error.toString(),
      ),
      (response) {
        final incoming = response.items ?? [];
        final merged = replace
            ? incoming
            : [...state.organizers, ...incoming];
        state = state.copyWith(
          stateConstant: StateConstant.success,
          organizers: merged,
          currentPage: page,
          hasMore: response.hasNextPage,
          isLoadingMore: false,
          subscribedCount: response.subCount,
        );
        // Update global subscriptions
        final subs = <String, bool>{};
        for (final org in merged) {
          if (org.id != null && org.isFollowing != null) {
            subs[org.id!] = org.isFollowing!;
          }
        }
        ref.read(organizerSubscriptionsProvider.notifier).setSubscriptions(subs);
      },
    );
  }

  Future<void> fetchRecommendations() async {
    state = state.copyWith(recommendationsState: StateConstant.loading);
    final result = await _recommendationsUseCase.call(const NoParams());
    if (!ref.mounted) return;
    result.fold(
      (error) => state = state.copyWith(
        recommendationsState: StateConstant.error,
        recommendationsMessage: error.toString(),
      ),
      (response) {
        state = state.copyWith(
          recommendationsState: StateConstant.success,
          recommendations: response.items ?? [],
        );
        // Update global subscriptions for recommendations
        final subs = <String, bool>{};
        for (final org in response.items ?? []) {
          if (org.id != null && org.isFollowing != null) {
            subs[org.id!] = org.isFollowing!;
          }
        }
        ref.read(organizerSubscriptionsProvider.notifier).setSubscriptions(subs);
      },
    );
  }

  void updateSubscription(String userId, bool isFollowing) {
    int? newCount;
    if (state.subscribedCount != null) {
      final delta = isFollowing ? 1 : -1;
      newCount = (state.subscribedCount! + delta).clamp(0, 1 << 30);
    }
    state = state.copyWith(
      organizers: state.organizers
          .map((o) => o.id == userId ? o.copyWith(isFollowing: isFollowing) : o)
          .toList(),
      recommendations: state.recommendations
          .map((o) => o.id == userId ? o.copyWith(isFollowing: isFollowing) : o)
          .toList(),
      subscribedCount: newCount,
    );
  }
}
