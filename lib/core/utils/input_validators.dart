import '../constants/app_strings.dart';
import '../extensions/string_extensions.dart';

abstract final class InputValidators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  static String? email(String? value) {
    final requiredResult = requiredField(value);
    if (requiredResult != null) return requiredResult;

    if (!value!.isValidEmail) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    final requiredResult = requiredField(value);
    if (requiredResult != null) return requiredResult;

    if (!value!.hasMinPasswordLength) {
      return AppStrings.weakPassword;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredResult = requiredField(value);
    if (requiredResult != null) return requiredResult;

    if (value!.trim() != password.trim()) {
      return AppStrings.passwordMismatch;
    }
    return null;
  }
}