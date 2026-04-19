enum ResumeTemplate {
  classic,
  modern,
  minimal,
}

extension ResumeTemplateX on ResumeTemplate {
  String get label => switch (this) {
        ResumeTemplate.classic => 'Classic',
        ResumeTemplate.modern => 'Modern',
        ResumeTemplate.minimal => 'Minimal',
      };
}
