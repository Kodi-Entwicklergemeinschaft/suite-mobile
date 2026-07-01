enum SourceType {
  manual,
  scraper,
  integration,
  apiImport; // api_import in API

  String toApiValue() {
    switch (this) {
      case SourceType.apiImport:
        return 'api_import';
      default:
        return name;
    }
  }

  static SourceType? fromApiValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'api_import':
        return SourceType.apiImport;
      case 'manual':
        return SourceType.manual;
      case 'scraper':
        return SourceType.scraper;
      case 'integration':
        return SourceType.integration;
      default:
        return null;
    }
  }
}
