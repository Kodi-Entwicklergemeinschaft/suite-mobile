import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateFilterState {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateFilterState({this.startDate, this.endDate});

  bool get hasActiveFilters => startDate != null || endDate != null;

  DateFilterState copyWith({DateTime? startDate, DateTime? endDate}) {
    return DateFilterState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// Global (not family) — one shared date filter per screen that holds it
final dateFilterControllerProvider =
    NotifierProvider<DateFilterController, DateFilterState>(
  () => DateFilterController(),
);

class DateFilterController extends Notifier<DateFilterState> {
  @override
  DateFilterState build() => const DateFilterState();

  void updateRange(DateTime? start, DateTime? end) {
    state = DateFilterState(startDate: start, endDate: end);
  }

  void reset() {
    state = const DateFilterState();
  }
}
