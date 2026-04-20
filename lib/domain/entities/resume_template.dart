enum ResumeTemplate {
  classic,
  modern,
  modernClean,
  modernSidebar,
  minimal,
  executive,
}

extension ResumeTemplateX on ResumeTemplate {
  String get label => switch (this) {
        ResumeTemplate.classic => 'Classic',
        ResumeTemplate.modern => 'Modern',
        ResumeTemplate.modernClean => 'Modern Clean',
        ResumeTemplate.modernSidebar => 'Modern Sidebar',
        ResumeTemplate.minimal => 'Minimal',
        ResumeTemplate.executive => 'Executive',
      };
}
