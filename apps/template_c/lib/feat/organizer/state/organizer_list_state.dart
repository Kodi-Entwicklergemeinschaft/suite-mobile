import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/organizer/data/models/organizer_model.dart';

class OrganizerListState {
  final StateConstant stateConstant;
  final List<OrganizerModel> organizers;
  final String message;
  final StateConstant recommendationsState;
  final List<OrganizerModel> recommendations;
  final String recommendationsMessage;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  // null = not provided by API; use local fallback
  final int? subscribedCount;

  OrganizerListState(
    this.stateConstant,
    this.organizers,
    this.message, {
    this.recommendationsState = StateConstant.loading,
    this.recommendations = const [],
    this.recommendationsMessage = '',
    this.hasMore = false,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.subscribedCount,
  });

  OrganizerListState copyWith({
    StateConstant? stateConstant,
    List<OrganizerModel>? organizers,
    String? message,
    StateConstant? recommendationsState,
    List<OrganizerModel>? recommendations,
    String? recommendationsMessage,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    int? subscribedCount,
  }) =>
      OrganizerListState(
        stateConstant ?? this.stateConstant,
        organizers ?? this.organizers,
        message ?? this.message,
        recommendationsState: recommendationsState ?? this.recommendationsState,
        recommendations: recommendations ?? this.recommendations,
        recommendationsMessage:
            recommendationsMessage ?? this.recommendationsMessage,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        subscribedCount: subscribedCount ?? this.subscribedCount,
      );
}
