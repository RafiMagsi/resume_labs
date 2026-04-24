enum ResumeTemplate {
  // Tech & IT
  classic,
  modern,
  modernClean,
  minimal,

  // Business & Management
  executive,
  modernSidebar,

  // AI & Data Science
  datascience,

  // Sales & Business Development
  sales,

  // Marketing & Communications
  marketing,

  // Finance & Accounting
  finance,

  // Creative & Design
  creative,

  // Academic & Research
  academic,

  // Healthcare & Medical
  healthcare,

  // Startup & Entrepreneurship
  startup,
}

enum TemplateProfession {
  tech,
  aiData,
  sales,
  marketing,
  finance,
  business,
  creative,
  academic,
  healthcare,
  startup,
}

extension ResumeTemplateX on ResumeTemplate {
  String get label => switch (this) {
        ResumeTemplate.classic => 'Classic',
        ResumeTemplate.modern => 'Modern',
        ResumeTemplate.modernClean => 'Modern Clean',
        ResumeTemplate.modernSidebar => 'Modern Sidebar',
        ResumeTemplate.minimal => 'Minimal',
        ResumeTemplate.executive => 'Executive',
        ResumeTemplate.datascience => 'Data Science',
        ResumeTemplate.sales => 'Sales',
        ResumeTemplate.marketing => 'Marketing',
        ResumeTemplate.finance => 'Finance',
        ResumeTemplate.creative => 'Creative',
        ResumeTemplate.academic => 'Academic',
        ResumeTemplate.healthcare => 'Healthcare',
        ResumeTemplate.startup => 'Startup',
      };

  String get displayName => switch (this) {
        ResumeTemplate.classic => 'Classic',
        ResumeTemplate.modern => 'Modern',
        ResumeTemplate.modernClean => 'Modern Clean',
        ResumeTemplate.modernSidebar => 'Sidebar',
        ResumeTemplate.minimal => 'Minimal',
        ResumeTemplate.executive => 'Executive',
        ResumeTemplate.datascience => 'Data Sci',
        ResumeTemplate.sales => 'Sales',
        ResumeTemplate.marketing => 'Marketing',
        ResumeTemplate.finance => 'Finance',
        ResumeTemplate.creative => 'Creative',
        ResumeTemplate.academic => 'Academic',
        ResumeTemplate.healthcare => 'Health',
        ResumeTemplate.startup => 'Startup',
      };

  String get description => switch (this) {
        ResumeTemplate.classic => 'Timeless professional design',
        ResumeTemplate.modern => 'Contemporary with modern accents',
        ResumeTemplate.modernClean => 'Clean, structured layout',
        ResumeTemplate.modernSidebar => 'Two-column with skills sidebar',
        ResumeTemplate.minimal => 'Minimalist approach',
        ResumeTemplate.executive => 'Formal executive design',
        ResumeTemplate.datascience => 'Technical layout for AI/ML',
        ResumeTemplate.sales => 'Results-focused design',
        ResumeTemplate.marketing => 'Engaging creative layout',
        ResumeTemplate.finance => 'Professional with trust accents',
        ResumeTemplate.creative => 'Bold, vibrant design',
        ResumeTemplate.academic => 'Formal CV style',
        ResumeTemplate.healthcare => 'Clinical professional design',
        ResumeTemplate.startup => 'Dynamic, innovative design',
      };

  TemplateProfession get profession => switch (this) {
        ResumeTemplate.classic => TemplateProfession.business,
        ResumeTemplate.modern => TemplateProfession.tech,
        ResumeTemplate.modernClean => TemplateProfession.tech,
        ResumeTemplate.modernSidebar => TemplateProfession.business,
        ResumeTemplate.minimal => TemplateProfession.tech,
        ResumeTemplate.executive => TemplateProfession.business,
        ResumeTemplate.datascience => TemplateProfession.aiData,
        ResumeTemplate.sales => TemplateProfession.sales,
        ResumeTemplate.marketing => TemplateProfession.marketing,
        ResumeTemplate.finance => TemplateProfession.finance,
        ResumeTemplate.creative => TemplateProfession.creative,
        ResumeTemplate.academic => TemplateProfession.academic,
        ResumeTemplate.healthcare => TemplateProfession.healthcare,
        ResumeTemplate.startup => TemplateProfession.startup,
      };
}
