enum Visibility {
  public,
  tenantOnly, // tenant_only in API
  private;

  String toApiValue() {
    switch (this) {
      case Visibility.tenantOnly:
        return 'tenant_only';
      default:
        return name;
    }
  }

  static Visibility? fromApiValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'tenant_only':
        return Visibility.tenantOnly;
      case 'public':
        return Visibility.public;
      case 'private':
        return Visibility.private;
      default:
        return null;
    }
  }
}
