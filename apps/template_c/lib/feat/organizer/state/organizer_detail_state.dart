import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/organizer/data/models/organizer_detail_model.dart';

class OrganizerDetailState {
  final StateConstant stateConstant;
  final OrganizerDetailModel? detail;
  final String message;
  final bool isLoadingMoreEvents;

  OrganizerDetailState(
    this.stateConstant,
    this.detail,
    this.message, {
    this.isLoadingMoreEvents = false,
  });

  OrganizerDetailState copyWith({
    StateConstant? stateConstant,
    OrganizerDetailModel? detail,
    String? message,
    bool? isLoadingMoreEvents,
  }) =>
      OrganizerDetailState(
        stateConstant ?? this.stateConstant,
        detail ?? this.detail,
        message ?? this.message,
        isLoadingMoreEvents: isLoadingMoreEvents ?? this.isLoadingMoreEvents,
      );
}
