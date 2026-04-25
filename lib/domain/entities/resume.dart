import 'education.dart';
import 'contact_details.dart';
import 'resume_template.dart';
import 'skill.dart';
import 'work_experience.dart';

class Resume {
  final String id;
  final String userId;
  final String title;
  final String personalSummary;
  final String? photoUrl;
  final ContactDetails contactDetails;
  final ResumeTemplate template;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Resume({
    required this.id,
    required this.userId,
    required this.title,
    required this.personalSummary,
    this.photoUrl,
    this.contactDetails = const ContactDetails(),
    this.template = ResumeTemplate.classic,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.createdAt,
    required this.updatedAt,
  });

  Resume copyWith({
    String? id,
    String? userId,
    String? title,
    String? personalSummary,
    String? photoUrl,
    ContactDetails? contactDetails,
    ResumeTemplate? template,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<Skill>? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resume(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      personalSummary: personalSummary ?? this.personalSummary,
      photoUrl: photoUrl ?? this.photoUrl,
      contactDetails: contactDetails ?? this.contactDetails,
      template: template ?? this.template,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Resume &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.personalSummary == personalSummary &&
        other.photoUrl == photoUrl &&
        other.contactDetails == contactDetails &&
        other.template == template &&
        _listEquals(other.workExperiences, workExperiences) &&
        _listEquals(other.educations, educations) &&
        _listEquals(other.skills, skills) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        personalSummary.hashCode ^
        (photoUrl?.hashCode ?? 0) ^
        contactDetails.hashCode ^
        template.hashCode ^
        Object.hashAll(workExperiences) ^
        Object.hashAll(educations) ^
        Object.hashAll(skills) ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
