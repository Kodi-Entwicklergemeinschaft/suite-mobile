enum HomeScreenConstant {
  contentSliderV1('content_slider_v1'),
  contentSliderV2('content_slider_v2'),
  contentSliderV3('content_slider_v3');

  final String value;
  const HomeScreenConstant(this.value);

  static HomeScreenConstant? fromValue(String? value) {
    if (value == null) return null;
    return HomeScreenConstant.values.where((e) => e.value == value).firstOrNull;
  }
}

/// Stable filter keys for the week day listing views.
/// Keys are fixed English identifiers — independent of display labels/translations.
/// [dayOffset] is days from Monday of the current week (0 = Mon … 6 = Sun).
enum HomeWeekDay {
  monday(filterKey: 'monday', dayOffset: 0),
  tuesday(filterKey: 'tuesday', dayOffset: 1),
  wednesday(filterKey: 'wednesday', dayOffset: 2),
  thursday(filterKey: 'thursday', dayOffset: 3),
  friday(filterKey: 'friday', dayOffset: 4),
  saturday(filterKey: 'saturday', dayOffset: 5),
  sunday(filterKey: 'sunday', dayOffset: 6);

  final String filterKey;
  final int dayOffset;
  const HomeWeekDay({required this.filterKey, required this.dayOffset});
}
