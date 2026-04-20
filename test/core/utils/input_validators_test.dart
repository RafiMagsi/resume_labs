import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/core/constants/app_strings.dart';
import 'package:resume_labs/core/utils/input_validators.dart';

void main() {
  group('InputValidators', () {
    group('requiredField', () {
      test('returns error when null/empty/whitespace', () {
        expect(InputValidators.requiredField(null), AppStrings.fieldRequired);
        expect(InputValidators.requiredField(''), AppStrings.fieldRequired);
        expect(InputValidators.requiredField('   '), AppStrings.fieldRequired);
      });

      test('returns null when non-empty', () {
        expect(InputValidators.requiredField('a'), isNull);
        expect(InputValidators.requiredField('  a  '), isNull);
      });
    });

    group('email', () {
      test('returns required error when empty', () {
        expect(InputValidators.email(null), AppStrings.fieldRequired);
        expect(InputValidators.email(''), AppStrings.fieldRequired);
      });

      test('returns invalidEmail error when not a valid email', () {
        expect(InputValidators.email('not-an-email'), AppStrings.invalidEmail);
      });

      test('returns null when valid email', () {
        expect(InputValidators.email('test@example.com'), isNull);
      });
    });

    group('password', () {
      test('returns required error when empty', () {
        expect(InputValidators.password(null), AppStrings.fieldRequired);
        expect(InputValidators.password(''), AppStrings.fieldRequired);
      });

      test('returns weakPassword when length < 8', () {
        expect(InputValidators.password('1234567'), AppStrings.weakPassword);
      });

      test('returns null when length >= 8', () {
        expect(InputValidators.password('12345678'), isNull);
      });
    });

    group('confirmPassword', () {
      test('returns required error when empty', () {
        expect(
          InputValidators.confirmPassword(null, 'password'),
          AppStrings.fieldRequired,
        );
      });

      test('returns mismatch when passwords differ (trims)', () {
        expect(
          InputValidators.confirmPassword('a', 'b'),
          AppStrings.passwordMismatch,
        );
        expect(
          InputValidators.confirmPassword('  a  ', 'a1'),
          AppStrings.passwordMismatch,
        );
      });

      test('returns null when passwords match', () {
        expect(InputValidators.confirmPassword('pass', 'pass'), isNull);
        expect(InputValidators.confirmPassword(' pass ', 'pass'), isNull);
      });
    });
  });
}
