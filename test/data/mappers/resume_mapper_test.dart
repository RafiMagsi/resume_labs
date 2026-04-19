import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/mappers/resume_mapper.dart';
import 'package:resume_labs/data/models/education_model.dart';
import 'package:resume_labs/data/models/resume_model.dart';
import 'package:resume_labs/data/models/skill_model.dart';
import 'package:resume_labs/data/models/work_experience_model.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';

void main() {
  group('ResumeMapper', () {
    test('toEntity maps model to entity correctly', () {
      final model = ResumeModel(
        id: '1',
        userId: 'user-1',
        title: 'Senior Flutter Developer',
        personalSummary: 'Experienced mobile developer',
        workExperiences: [
          WorkExperienceModel(
            company: 'ABC',
            role: 'Developer',
            location: 'Dubai',
            startDate: DateTime(2021, 1, 1),
            endDate: null,
            bulletPoints: const ['Built app'],
            isCurrentRole: true,
          ),
        ],
        educations: [
          EducationModel(
            school: 'XYZ University',
            degree: 'BS',
            field: 'CS',
            graduationDate: DateTime(2019, 6, 1),
            gpa: 3.5,
          ),
        ],
        skills: const [
          SkillModel(
            name: 'Flutter',
            category: 'Frontend',
          ),
        ],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 2, 1),
      );

      final entity = model.toEntity();

      expect(
        entity,
        Resume(
          id: '1',
          userId: 'user-1',
          title: 'Senior Flutter Developer',
          personalSummary: 'Experienced mobile developer',
          workExperiences: [
            WorkExperience(
              company: 'ABC',
              role: 'Developer',
              location: 'Dubai',
              startDate: DateTime(2021, 1, 1),
              endDate: null,
              bulletPoints: const ['Built app'],
              isCurrentRole: true,
            ),
          ],
          educations: [
            Education(
              school: 'XYZ University',
              degree: 'BS',
              field: 'CS',
              graduationDate: DateTime(2019, 6, 1),
              gpa: 3.5,
            ),
          ],
          skills: const [
            Skill(
              name: 'Flutter',
              category: 'Frontend',
            ),
          ],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 2, 1),
        ),
      );
    });

    test('toModel maps entity to model correctly', () {
      final entity = Resume(
        id: '2',
        userId: 'user-2',
        title: 'iOS Engineer',
        personalSummary: 'Native iOS specialist',
        workExperiences: [
          WorkExperience(
            company: 'Apple Partner',
            role: 'iOS Engineer',
            location: 'Remote',
            startDate: DateTime(2020, 1, 1),
            endDate: DateTime(2022, 1, 1),
            bulletPoints: const ['Shipped iOS app'],
            isCurrentRole: false,
          ),
        ],
        educations: [
          Education(
            school: 'FAST',
            degree: 'BS',
            field: 'SE',
            graduationDate: DateTime(2018, 6, 1),
            gpa: null,
          ),
        ],
        skills: const [
          Skill(
            name: 'Swift',
            category: 'Mobile',
          ),
        ],
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      final model = entity.toModel();

      expect(
        model,
        ResumeModel(
          id: '2',
          userId: 'user-2',
          title: 'iOS Engineer',
          personalSummary: 'Native iOS specialist',
          workExperiences: [
            WorkExperienceModel(
              company: 'Apple Partner',
              role: 'iOS Engineer',
              location: 'Remote',
              startDate: DateTime(2020, 1, 1),
              endDate: DateTime(2022, 1, 1),
              bulletPoints: const ['Shipped iOS app'],
              isCurrentRole: false,
            ),
          ],
          educations: [
            EducationModel(
              school: 'FAST',
              degree: 'BS',
              field: 'SE',
              graduationDate: DateTime(2018, 6, 1),
              gpa: null,
            ),
          ],
          skills: const [
            SkillModel(
              name: 'Swift',
              category: 'Mobile',
            ),
          ],
          createdAt: DateTime(2024, 3, 1),
          updatedAt: DateTime(2024, 4, 1),
        ),
      );
    });
  });
}