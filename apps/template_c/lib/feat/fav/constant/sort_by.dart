enum SortBy {
  title,
  eventStart,
  viewCount,
  likeCount,
  updatedAt,
  createdAt;

  String toApiValue() => name;

  static SortBy? fromApiValue(String? value) {
    if (value == null) return null;
    for (final e in SortBy.values) {
      if (e.name == value) return e;
    }
    return null;
  }
}
