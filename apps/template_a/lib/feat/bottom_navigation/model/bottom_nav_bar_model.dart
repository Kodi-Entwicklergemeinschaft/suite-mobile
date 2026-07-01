class BottomNavBarModel {
  final List<NavItemModel> items;

  BottomNavBarModel({
    required this.items,
  });
}

class NavItemModel {
  final String iconUrl;
  final String? label;

  NavItemModel({
    required this.iconUrl,
    this.label,
  });
}
