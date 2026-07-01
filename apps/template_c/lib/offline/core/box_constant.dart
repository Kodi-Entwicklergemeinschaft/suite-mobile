enum BoxKey {
  templateC('template_c');

  final String name;

  const BoxKey(this.name);
}

enum BoxItemKeyConstant {
  favKey('fav_key'),
  unselectedFavKey('unselected_fav_key'),
  themeKey('theme_key'),
  bottomNavConfigKey('bottom_nav_config');

  final String name;

  const BoxItemKeyConstant(this.name);
}
