/// Resolves template placeholders in CMS-provided label strings.
///
/// Supported placeholders:
///   - `{{LOCALITY}}` — replaced with the first segment of [selectedLocation]
///     (i.e. the part before the first comma). Falls back to [fallback] when
///     no location is available.
String resolveLabel(
  String? label, {
  required String? selectedLocation,
  String fallback = '',
}) {
  if (label == null) return fallback;
  if (!label.contains('{{LOCALITY}}')) return label;

  final locality =
      selectedLocation?.split(',').first.trim().isNotEmpty == true
          ? selectedLocation!.split(',').first.trim()
          : fallback;

  return label.replaceAll('{{LOCALITY}}', locality);
}
