/// Specialized data model for form steps
///
/// This provides structured handling of form fields, validation states,
/// and form data.
class FormStepData {
  /// The form data as key-value pairs
  final Map<String, dynamic> formData;

  /// Set of form fields that have been touched/edited
  final Set<String> touchedFields;

  /// Set of fields that have been validated successfully
  final Set<String> validFields;

  /// Set of fields that have validation errors with their error messages
  final Map<String, String> fieldErrors;

  /// Whether the entire form is valid
  final bool isFormValid;

  /// Whether the form has been submitted
  final bool isSubmitted;

  /// Global form error message if any
  final String? formError;

  /// Creates a new [FormStepData]
  const FormStepData({
    this.formData = const {},
    this.touchedFields = const {},
    this.validFields = const {},
    this.fieldErrors = const {},
    this.isFormValid = false,
    this.isSubmitted = false,
    this.formError,
  });

  /// Creates a FormStepData from JSON
  factory FormStepData.fromJson(Map<String, dynamic> json) => FormStepData(
    formData: Map<String, dynamic>.from(json['formData'] ?? {}),
    touchedFields: Set<String>.from(
      (json['touchedFields'] ?? []).cast<String>(),
    ),
    validFields: Set<String>.from((json['validFields'] ?? []).cast<String>()),
    fieldErrors: Map<String, String>.from(
      (json['fieldErrors'] ?? {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    ),
    isFormValid: json['isFormValid'] ?? false,
    isSubmitted: json['isSubmitted'] ?? false,
    formError: json['formError'],
  );

  /// Converts to JSON
  Map<String, dynamic> toJson() => {
    'formData': formData,
    'touchedFields': touchedFields.toList(),
    'validFields': validFields.toList(),
    'fieldErrors': fieldErrors,
    'isFormValid': isFormValid,
    'isSubmitted': isSubmitted,
    'formError': formError,
  };

  /// Creates a copy with modified properties
  FormStepData copyWith({
    Map<String, dynamic>? formData,
    Set<String>? touchedFields,
    Set<String>? validFields,
    Map<String, String>? fieldErrors,
    bool? isFormValid,
    bool? isSubmitted,
    String? formError,
    bool clearFormError = false,
  }) {
    return FormStepData(
      formData: formData ?? this.formData,
      touchedFields: touchedFields ?? this.touchedFields,
      validFields: validFields ?? this.validFields,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isFormValid: isFormValid ?? this.isFormValid,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      formError: clearFormError ? null : (formError ?? this.formError),
    );
  }

  /// Gets a field value with optional type casting
  T? getField<T>(String fieldName, [T? defaultValue]) {
    if (!formData.containsKey(fieldName)) {
      return defaultValue;
    }

    final value = formData[fieldName];
    if (value is T) {
      return value;
    }

    // Basic type conversion for common types
    if (T == String && value != null) {
      return value.toString() as T;
    } else if (T == int && value is num) {
      return value.toInt() as T;
    } else if (T == double && value is num) {
      return value.toDouble() as T;
    } else if (T == bool && value is String) {
      return (value.toLowerCase() == 'true') as T;
    }

    return defaultValue;
  }

  /// Updates a field value
  FormStepData updateField(String fieldName, dynamic value) {
    final updatedFormData = Map<String, dynamic>.from(formData);
    updatedFormData[fieldName] = value;

    final updatedTouchedFields = Set<String>.from(touchedFields)
      ..add(fieldName);

    return copyWith(
      formData: updatedFormData,
      touchedFields: updatedTouchedFields,
    );
  }

  /// Sets a field as valid
  FormStepData setFieldValid(String fieldName) {
    final updatedValidFields = Set<String>.from(validFields)..add(fieldName);
    final updatedFieldErrors = Map<String, String>.from(fieldErrors)
      ..remove(fieldName);

    return copyWith(
      validFields: updatedValidFields,
      fieldErrors: updatedFieldErrors,
    );
  }

  /// Sets a field as invalid with an error message
  FormStepData setFieldInvalid(String fieldName, String errorMessage) {
    final updatedValidFields = Set<String>.from(validFields)..remove(fieldName);
    final updatedFieldErrors = Map<String, String>.from(fieldErrors)
      ..[fieldName] = errorMessage;

    return copyWith(
      validFields: updatedValidFields,
      fieldErrors: updatedFieldErrors,
    );
  }

  /// Checks if a field has been touched/edited
  bool isFieldTouched(String fieldName) => touchedFields.contains(fieldName);

  /// Checks if a field is valid
  bool isFieldValid(String fieldName) => validFields.contains(fieldName);

  /// Gets the error message for a field if any
  String? getFieldError(String fieldName) => fieldErrors[fieldName];

  /// Validates the entire form using the provided validation functions
  FormStepData validateForm(Map<String, String? Function(dynamic)> validators) {
    FormStepData result = this;
    bool allValid = true;

    validators.forEach((fieldName, validator) {
      final value = formData[fieldName];
      final errorMessage = validator(value);

      if (errorMessage == null) {
        // Field is valid
        result = result.setFieldValid(fieldName);
      } else {
        // Field is invalid
        result = result.setFieldInvalid(fieldName, errorMessage);
        allValid = false;
      }
    });

    return result.copyWith(isFormValid: allValid);
  }

  /// Marks the form as submitted
  FormStepData submit() => copyWith(isSubmitted: true);

  /// Resets the form to initial state but keeps the form data
  FormStepData reset() => copyWith(
    touchedFields: {},
    validFields: {},
    fieldErrors: {},
    isFormValid: false,
    isSubmitted: false,
    formError: null,
  );

  /// Clears all form data and resets the form
  FormStepData clear() => const FormStepData();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormStepData &&
        _mapsEqual(other.formData, formData) &&
        _setsEqual(other.touchedFields, touchedFields) &&
        _setsEqual(other.validFields, validFields) &&
        _mapsEqual(other.fieldErrors, fieldErrors) &&
        other.isFormValid == isFormValid &&
        other.isSubmitted == isSubmitted &&
        other.formError == formError;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(formData.entries),
    Object.hashAll(touchedFields),
    Object.hashAll(validFields),
    Object.hashAll(fieldErrors.entries),
    isFormValid,
    isSubmitted,
    formError,
  );

  /// Helper method to compare maps
  bool _mapsEqual(Map map1, Map map2) {
    if (identical(map1, map2)) return true;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }

    return true;
  }

  /// Helper method to compare sets
  bool _setsEqual(Set set1, Set set2) {
    if (identical(set1, set2)) return true;
    if (set1.length != set2.length) return false;

    for (final item in set1) {
      if (!set2.contains(item)) {
        return false;
      }
    }

    return true;
  }
}
