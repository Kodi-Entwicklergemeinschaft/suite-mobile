enum ListingVisibility {
  public,
  tenantOnly,
  private;

  String toApiValue() {
    switch (this) {
      case ListingVisibility.tenantOnly:
        return 'tenant_only';
      default:
        return name;
    }
  }

  static ListingVisibility? fromApiValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'tenant_only':
        return ListingVisibility.tenantOnly;
      case 'public':
        return ListingVisibility.public;
      case 'private':
        return ListingVisibility.private;
      default:
        return null;
    }
  }
}
