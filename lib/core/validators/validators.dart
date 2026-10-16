import '../security/request_security.dart';

class Validators {
  static bool validAmount(String value, {double minimum = 0, double? maximum}) {
    final number = double.tryParse(value.trim().replaceAll(',', '.'));
    return number != null &&
        number.isFinite &&
        number >= minimum &&
        (maximum == null || number <= maximum) &&
        (number * 1000).isFinite &&
        (number * 1000 - (number * 1000).round()).abs() < 0.000001;
  }

  static bool validStaffUsername(String value) =>
      RegExp(r'^[a-zA-Z0-9_-]{3,20}$').hasMatch(value.trim());
  static bool validStaffPassword(String value,
          {bool creating = false}) =>
      (creating
              ? RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9]{8,}$')
              : RegExp(
                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9@$!%*?&]{8,}$'))
          .hasMatch(value);
  static String? validateOptionalText(String? value) =>
      value == null || RequestSecurity.safeText(value) ? null : 'Invalid text';
  static String? validateOptionalEmail(String? value) =>
      value == null || value.trim().isEmpty ? null : validateEmail(value);
  static String? validateOptionalPhone(String? value) =>
      value == null || value.trim().isEmpty ? null : validatePhone(value);
  static String? validateOptionalWebsite(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      RequestSecurity.webUri(value.trim());
      return null;
    } on FormatException {
      return 'Enter a valid web address';
    }
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length > RequestSecurity.maxText) return 'Invalid password';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RequestSecurity.validEmail(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (!RequestSecurity.safeText(value)) return 'Invalid name';
    return null;
  }

  static String normalizePhone(String value) =>
      RequestSecurity.normalizePhone(value);

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    if (!RequestSecurity.validPhone(value)) {
      return 'Phone must be 8 digits and start with 4, 5, 6, or 9';
    }

    return null;
  }
}
