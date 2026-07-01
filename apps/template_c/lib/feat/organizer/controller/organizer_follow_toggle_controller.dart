import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/organizer/controller/organizer_detail_controller.dart';
import 'package:template_c/feat/organizer/controller/organizer_list_controller.dart';
import 'package:template_c/feat/organizer/domain/usecases/toggle_organizer_follow_usecase.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';

final organizerSubscriptionsProvider = NotifierProvider<OrganizerSubscriptionsNotifier, Map<String, bool>>(
  () => OrganizerSubscriptionsNotifier(),
);

class OrganizerSubscriptionsNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {};

  void updateSubscription(String id, bool isFollowing) {
    state = {...state, id: isFollowing};
  }

  void setSubscriptions(Map<String, bool> subs) {
    state = {...state, ...subs};
  }
}

final organizerToggleControllerProvider = Provider<OrganizerFollowToggleController>(
  (ref) => OrganizerFollowToggleController(ref),
);

class OrganizerFollowToggleController {
  final Ref _ref;

  OrganizerFollowToggleController(this._ref);

  Future<void> toggle(String userId, {required bool subscribe}) async {
    final result = await _ref
        .read(toggleOrganizerFollowUseCaseProvider)
        .call(userId, subscribe: subscribe);

    result.fold(
      (_) {}, // API failed — leave UI unchanged
      (_) {
        // API succeeded — update locally without refetching
        _ref
            .read(organizerSubscriptionsProvider.notifier)
            .updateSubscription(userId, subscribe);
        _ref
            .read(organizerListControllerProvider.notifier)
            .updateSubscription(userId, subscribe);

        final detailProvider = organizerDetailControllerProvider(userId);
        if (_ref.exists(detailProvider)) {
          _ref.read(detailProvider.notifier).updateSubscription(subscribe);
        }

        // Refresh profile to update counts
        if (_ref.exists(profileControllerProvider)) {
          _ref.read(profileControllerProvider.notifier).getProfile();
        }
      },
    );
  }
}
