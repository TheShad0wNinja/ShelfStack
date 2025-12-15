/// Represents a form validation response with support for field-specific or general errors.
class FormValidationResponse {
  final bool isValid;
  final String? generalError;
  final Map<String, String> fieldErrors;

  FormValidationResponse({
    required this.isValid,
    this.generalError,
    this.fieldErrors = const {},
  });

  /// Creates a successful validation response.
  factory FormValidationResponse.success() {
    return FormValidationResponse(
      isValid: true,
      fieldErrors: {},
    );
  }

  /// Creates a response with a general error (not field-specific).
  factory FormValidationResponse.generalError(String message) {
    return FormValidationResponse(
      isValid: false,
      generalError: message,
      fieldErrors: {},
    );
  }

  /// Creates a response with field-specific errors.
  factory FormValidationResponse.fieldErrors(Map<String, String> errors) {
    return FormValidationResponse(
      isValid: false,
      fieldErrors: errors,
    );
  }

  /// Creates a response with both general and field-specific errors.
  factory FormValidationResponse.mixed({
    required String generalError,
    required Map<String, String> fieldErrors,
  }) {
    return FormValidationResponse(
      isValid: false,
      generalError: generalError,
      fieldErrors: fieldErrors,
    );
  }

  /// Check if a specific field has an error.
  bool hasFieldError(String fieldName) {
    return fieldErrors.containsKey(fieldName);
  }

  /// Get error message for a specific field.
  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  /// Check if there's a general error.
  bool hasGeneralError() {
    return generalError != null && generalError!.isNotEmpty;
  }

  /// Get all error messages (both general and field-specific).
  List<String> getAllErrors() {
    final allErrors = <String>[];
    if (hasGeneralError()) {
      allErrors.add(generalError!);
    }
    allErrors.addAll(fieldErrors.values);
    return allErrors;
  }

  /// Check if there are any errors at all.
  bool hasAnyError() {
    return !isValid || hasGeneralError() || fieldErrors.isNotEmpty;
  }
}
