import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resume.dart';
import '../../../domain/entities/resume_template.dart';
import '../../../injection/injection_container.dart';

final docxExportProvider =
    AsyncNotifierProvider<DocxExportNotifier, DocxExportState>(
  DocxExportNotifier.new,
);

class DocxExportNotifier extends AsyncNotifier<DocxExportState> {
  @override
  Future<DocxExportState> build() async {
    return const DocxExportState();
  }

  Future<void> exportDocx({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(exportDocxUseCaseProvider);
    final result = await useCase(
      resume: resume,
      template: template,
    );

    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (filePath) => AsyncData(
        DocxExportState(
          exportedFilePath: filePath,
          successMessage: 'DOCX exported successfully.',
        ),
      ),
    );
  }

  void clear() {
    state = const AsyncData(DocxExportState());
  }
}

class DocxExportState {
  final String? exportedFilePath;
  final String? successMessage;

  const DocxExportState({
    this.exportedFilePath,
    this.successMessage,
  });

  bool get hasExportedFile =>
      exportedFilePath != null && exportedFilePath!.trim().isNotEmpty;

  bool get hasSuccessMessage =>
      successMessage != null && successMessage!.trim().isNotEmpty;
}
