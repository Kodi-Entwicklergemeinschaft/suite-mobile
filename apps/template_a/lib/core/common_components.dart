/// Common components for template_a
///
/// Import this file to access all template-specific widgets:
/// ```dart
/// import 'package:template_a/core/common_components.dart';
/// ``'

// Hide CommonTextField from common_components to avoid conflicts
export 'package:common_components/common_components.dart'
    hide CommonTextField;

// Export template_a's custom widgets
export 'widgets/common_text_field.dart';
