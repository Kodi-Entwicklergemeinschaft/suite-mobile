enum HomeScreenConstant {
  hamburgerMenu('hamburger_menu'),
  appiconImage('appicon_image'),
  headerImage('header_image'),
  searchBar('search_bar'),
  contentSliderV4('content_slider_v4'),
  contentSliderV5('content_slider_v5'),
  subCategorySlider('sub_category_slider'),
  contentSliderV6('content_slider_v6'),
  tileSlider('tile_slider'),
  serviceHubCard('service_hub_card');

  final String value;
  const HomeScreenConstant(this.value);

  static HomeScreenConstant? fromValue(String? value) {
    if (value == null) return null;
    return HomeScreenConstant.values.where((e) => e.value == value).firstOrNull;
  }
}
