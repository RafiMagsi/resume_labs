import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/domain/entities/resume_template.dart';

void main() {
  group('ResumeTemplate', () {
    test('labels are stable and non-empty', () {
      for (final template in ResumeTemplate.values) {
        expect(template.label.trim(), isNotEmpty);
      }
    });

    test('labels are unique', () {
      final labels = ResumeTemplate.values.map((e) => e.label).toList();
      expect(labels.toSet().length, labels.length);
    });

    test('known label mappings', () {
      expect(ResumeTemplate.classic.label, 'Classic');
      expect(ResumeTemplate.modern.label, 'Modern');
      expect(ResumeTemplate.modernClean.label, 'Modern Clean');
      expect(ResumeTemplate.modernSidebar.label, 'Modern Sidebar');
      expect(ResumeTemplate.minimal.label, 'Minimal');
      expect(ResumeTemplate.executive.label, 'Executive');
    });
  });
}
