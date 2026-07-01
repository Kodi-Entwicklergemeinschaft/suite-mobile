enum SortOrder {
  asc,
  desc;

  String toApiValue() => name;

  static SortOrder? fromApiValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'asc':
        return SortOrder.asc;
      case 'desc':
        return SortOrder.desc;
      default:
        return null;
    }
  }
}
