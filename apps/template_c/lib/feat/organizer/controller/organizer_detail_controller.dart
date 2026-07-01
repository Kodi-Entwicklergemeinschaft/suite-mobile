import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/organizer/controller/organizer_follow_toggle_controller.dart';
import 'package:template_c/feat/organizer/domain/usecases/get_organizer_detail_usecase.dart';
import 'package:template_c/feat/organizer/state/organizer_detail_state.dart';

final organizerDetailControllerProvider = NotifierProvider.family<
    OrganizerDetailController, OrganizerDetailState, String>(
  (id) => OrganizerDetailController(id),
);

class OrganizerDetailController extends Notifier<OrganizerDetailState> {
  final String _id;

  OrganizerDetailController(this._id);

  GetOrganizerDetailUseCase get _useCase =>
      ref.read(getOrganizerDetailUseCaseProvider);

  @override
  OrganizerDetailState build() =>
      OrganizerDetailState(StateConstant.loading, null, '');

  Future<void> fetchDetail() async {
    state = state.copyWith(stateConstant: StateConstant.loading);
    final result = await _useCase.call(_id, eventsPage: 1, eventsLimit: 10);
    if (!ref.mounted) return;
    result.fold(
      (error) => state = state.copyWith(
        stateConstant: StateConstant.error,
        message: error.toString(),
      ),
      (detail) {
        state = state.copyWith(
          stateConstant: StateConstant.success,
          detail: detail,
        );
        // Update global subscription
        if (detail.isFollowing != null) {
          ref.read(organizerSubscriptionsProvider.notifier).updateSubscription(_id, detail.isFollowing!);
        }
      },
    );
  }

  Future<void> loadMoreEvents() async {
    final detail = state.detail;
    if (detail == null) return;
    if (state.isLoadingMoreEvents) return;
    if (detail.eventsHasMore != true) return;

    state = state.copyWith(isLoadingMoreEvents: true);
    final nextPage = (detail.eventsCurrentPage ?? 1) + 1;
    final result = await _useCase.call(_id, eventsPage: nextPage, eventsLimit: 10);
    if (!ref.mounted) return;
    result.fold(
      (error) => state = state.copyWith(isLoadingMoreEvents: false),
      (newDetail) => state = state.copyWith(
        isLoadingMoreEvents: false,
        detail: detail.copyWith(
          upcomingEvents: [
            ...?detail.upcomingEvents,
            ...?newDetail.upcomingEvents,
          ],
          eventsCurrentPage: nextPage,
          eventsHasMore: newDetail.eventsHasMore,
          upcomingEventsTotal: newDetail.upcomingEventsTotal,
        ),
      ),
    );
  }

  void updateSubscription(bool isFollowing) {
    if (state.detail == null) return;
    state = state.copyWith(detail: state.detail!.copyWith(isFollowing: isFollowing));
  }
}
