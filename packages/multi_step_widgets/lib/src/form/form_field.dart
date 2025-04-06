import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for TextInputFormatter
import 'package:multi_step_flow/multi_step_flow.dart';

/// A form field widget that integrates with [FormStepData]
class FlowFormField extends StatelessWidget {
  /// The field name/key in the form data
  final String fieldName;

  /// The form data
  final FormStepData formData;

  /// Callback when field value changes
  final void Function(FormStepData) onChanged;

  /// Field validator function
  final String? Function(dynamic value)? validator;

  /// Input decoration for the field
  final InputDecoration? decoration;

  /// Whether the field is obscured (for passwords)
  final bool obscureText;

  /// Keyboard type for the field
  final TextInputType? keyboardType;

  /// TextInputAction for the field
  final TextInputAction? textInputAction;

  /// Focus node for the field
  final FocusNode? focusNode;

  /// Next focus node for the field (for moving to next field)
  final FocusNode? nextFocusNode;

  /// Formatter for the field
  final List<TextInputFormatter>? inputFormatters;

  /// Text style for the field
  final TextStyle? style;

  /// TextCapitalization for the field
  final TextCapitalization textCapitalization;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether to auto-validate the field
  final bool autovalidate;

  /// Maximum number of lines
  final int? maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum length of text
  final int? maxLength;

  /// Whether to show the counter
  final bool? showCounter;

  /// Constructor for [FlowFormField]
  const FlowFormField({
    super.key,
    required this.fieldName,
    required this.formData,
    required this.onChanged,
    this.validator,
    this.decoration,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.nextFocusNode,
    this.inputFormatters,
    this.style,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.autovalidate = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter,
  });

  @override
  Widget build(BuildContext context) {
    // Get current field value and error
    final value = formData.getField<String>(fieldName, '');
    final errorText = formData.getFieldError(fieldName);
    final isTouched = formData.isFieldTouched(fieldName);

    // Create controller with current value
    final controller = TextEditingController(text: value);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    // Build decoration
    final effectiveDecoration = (decoration ?? const InputDecoration())
        .copyWith(errorText: (isTouched || autovalidate) ? errorText : null);

    return TextFormField(
      controller: controller,
      decoration: effectiveDecoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: style,
      obscureText: obscureText,
      focusNode: focusNode,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      buildCounter:
          showCounter == false
              ? (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null
              : null,
      inputFormatters: inputFormatters,
      onChanged: (value) {
        // Update form data with new value
        FormStepData updatedData = formData.updateField(fieldName, value);

        // Validate if needed
        if (validator != null && (autovalidate || isTouched)) {
          final error = validator!(value);
          if (error == null) {
            updatedData = updatedData.setFieldValid(fieldName);
          } else {
            updatedData = updatedData.setFieldInvalid(fieldName, error);
          }
        }

        // Notify parent
        onChanged(updatedData);
      },
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },
    );
  }
}
