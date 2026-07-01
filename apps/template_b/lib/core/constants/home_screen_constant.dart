enum HomeScreenConstant {
  headerImage('header_image'),
  searchBar('search_bar'),
  hamburgerMenu('hamburger_menu'),
  quickActions('quick_actions'),
  localities('localities'),
  bannerImage('banner_image'),
  contentSlider('content_slider'),
  contentFeed('content_feed'),
  partners('partners');

  final String value;
  const HomeScreenConstant(this.value);

  static HomeScreenConstant? fromValue(String? value) {
    if (value == null) return null;
    return HomeScreenConstant.values.where((e) => e.value == value).firstOrNull;
  }
}
