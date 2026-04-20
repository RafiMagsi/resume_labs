import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/core/extensions/string_extensions.dart';

void main() {
  group('StringX', () {
    group('isValidEmail', () {
      test('returns true for valid emails (trims whitespace)', () {
        expect('test@example.com'.isValidEmail, isTrue);
        expect('  hello.world+1@test.co  '.isValidEmail, isTrue);
      });

      test('returns false for invalid emails', () {
        expect('not-an-email'.isValidEmail, isFalse);
        expect('test@'.isValidEmail, isFalse);
        expect('@example.com'.isValidEmail, isFalse);
        expect('test@example'.isValidEmail, isFalse);
      });
    });

    test('hasMinPasswordLength returns true only when >= 8 chars', () {
      expect('1234567'.hasMinPasswordLength, isFalse);
      expect('12345678'.hasMinPasswordLength, isTrue);
      expect('  12345678  '.hasMinPasswordLength, isTrue);
    });

    test('isNotBlank returns false for whitespace-only strings', () {
      expect(''.isNotBlank, isFalse);
      expect('   '.isNotBlank, isFalse);
      expect(' a '.isNotBlank, isTrue);
    });

    test('capitalize capitalizes the first character', () {
      expect('john'.capitalize, 'John');
      expect('John'.capitalize, 'John');
      expect('  '.capitalize, '  ');
    });

    test('initials returns initials from one or more words', () {
      expect(''.initials, '');
      expect('  '.initials, '');
      expect('john'.initials, 'J');
      expect('john doe'.initials, 'JD');
      expect('  john   doe  '.initials, 'JD');
      expect('john a doe'.initials, 'JD');
    });
  });
}
