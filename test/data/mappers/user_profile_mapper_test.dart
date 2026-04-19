import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/mappers/user_profile_mapper.dart' as mapper;
import 'package:resume_labs/data/models/user_profile_model.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';

void main() {
  group('UserProfileMapper', () {
    test('toEntity maps model to entity correctly', () {
      final model = UserProfileModel(
        uid: 'uid-1',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      final entity = mapper.UserProfileModelMapper(model).toEntity();

      expect(
        entity,
        UserProfile(
          uid: 'uid-1',
          email: 'test@example.com',
          createdAt: DateTime(2024, 1, 1),
        ),
      );
    });

    test('toModel maps entity to model correctly', () {
      final entity = UserProfile(
        uid: 'uid-2',
        email: 'other@example.com',
        createdAt: DateTime(2024, 2, 2),
      );

      final model = mapper.UserProfileEntityMapper(entity).toModel();

      expect(
        model,
        UserProfileModel(
          uid: 'uid-2',
          email: 'other@example.com',
          createdAt: DateTime(2024, 2, 2),
        ),
      );
    });
  });
}
