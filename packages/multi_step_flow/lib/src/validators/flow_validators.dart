import 'package:formz/formz.dart';

/// Base class for flow input validation
abstract class FlowInput<T> extends FormzInput<T, String> {
  const FlowInput.pure(super.value) : super.pure();
  const FlowInput.dirty(super.value) : super.dirty();
}

/// Required input validator
class RequiredInput<T> extends FlowInput<T?> {
  const RequiredInput.pure() : super.pure(null);
  const RequiredInput.dirty([super.value]) : super.dirty();

  @override
  String? validator(T? value) {
    if (value == null) return 'This field is required';
    if (value is String && value.isEmpty) return 'This field is required';
    return null;
  }
}

/// Email input validator
class EmailInput extends FlowInput<String> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!_emailRegExp.hasMatch(value)) return 'Invalid email format';
    return null;
  }
}

/// Password input validator
class PasswordInput extends FlowInput<String> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  static final _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!_passwordRegExp.hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }
}

/// Numeric input validator
class NumericInput extends FlowInput<String> {
  const NumericInput.pure() : super.pure('');
  const NumericInput.dirty([super.value = '']) : super.dirty();

  static final _numericRegExp = RegExp(r'^\d+$');

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'This field is required';
    if (!_numericRegExp.hasMatch(value)) return 'Must be numeric';
    return null;
  }
}

/// Phone number input validator
class PhoneInput extends FlowInput<String> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([super.value = '']) : super.dirty();

  static final _phoneRegExp = RegExp(r'^\+?[\d\s-]{10,}$');

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Phone number is required';
    if (!_phoneRegExp.hasMatch(value)) return 'Invalid phone number format';
    return null;
  }
}

/// URL input validator
class UrlInput extends FlowInput<String> {
  const UrlInput.pure() : super.pure('');
  const UrlInput.dirty([super.value = '']) : super.dirty();

  static final _urlRegExp = RegExp(
    r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$',
  );

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'URL is required';
    if (!_urlRegExp.hasMatch(value)) return 'Invalid URL format';
    return null;
  }
}

/// Date input validator
class DateInput extends FlowInput<DateTime?> {
  const DateInput.pure() : super.pure(null);
  const DateInput.dirty([super.value]) : super.dirty();

  @override
  String? validator(DateTime? value) {
    if (value == null) return 'Date is required';
    if (value.isAfter(DateTime.now())) return 'Date cannot be in the future';
    return null;
  }
}
