class ValidationHelper {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_field_required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'error_invalid_email';
    }
    return null;
  }

  // Password validation (min 6 chars, no spaces)
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_field_required';
    }
    if (value.length < 8) {
      return 'error_password_too_short';
    }
    if (value.contains(' ')) {
      return 'error_password_no_spaces';
    }
    return null;
  }

  // Username validation (6-15 chars, lowercase + numbers + underscore only, no spaces, no uppercase)
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_field_required';
    }
    if (value.length < 6) {
      return 'error_username_too_short';
    }
    if (value.length > 15) {
      return 'error_username_too_long';
    }
    if (value.contains(' ')) {
      return 'error_username_no_spaces';
    }
    // Only allows lowercase letters, numbers, and underscores for the entire string
    final usernameRegex = RegExp(r'^[a-z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'error_username_lowercase_only';
    }
    return null;
  }

  // Confirm password matching
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return 'error_field_required';
    }
    if (value != password) {
      return 'error_passwords_dont_match';
    }
    return null;
  }

  // Generic field validation (non-empty)
  static String? validateField(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'error_field_required';
    }
    return null;
  }

  // Name validation (letters, spaces, hyphens, apostrophes, periods only)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_field_required';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s\-'.]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'error_invalid_name';
    }
    return null;
  }

  // Phone number validation (digits and common separators: space, dash, parentheses, +)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_field_required';
    }
    // Remove common separators for validation
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-().]'), '');
    // Check if cleaned phone contains only digits and optional leading +
    final phoneRegex = RegExp(r'^\+?[0-9]+$');
    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'error_invalid_phone';
    }
    return null;
  }

  static String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final trimmed = value.trim();
    final normalized = trimmed.startsWith(RegExp(r'https?://'))
        ? trimmed
        : 'https://$trimmed';
    final websiteRegex = RegExp(
      r'^https?:\/\/(www\.)?[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}(\/\S*)?$',
    );
    if (!websiteRegex.hasMatch(normalized)) {
      return 'error_invalid_website';
    }
    return null;
  }
  
}
