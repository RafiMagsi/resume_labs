import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resume.dart';
import '../../../domain/entities/resume_template.dart';
import '../../../injection/injection_container.dart';

final pdfExportProvider =
    AsyncNotifierProvider<PdfExportNotifier, PdfExportState>(
  PdfExportNotifier.new,
);

class PdfExportNotifier extends AsyncNotifier<PdfExportState> {
  @override
  Future<PdfExportState> build() async {
    return const PdfExportState();
  }

  Future<void> exportPdf({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(exportPdfUseCaseProvider);
    final result = await useCase(
      resume: resume,
      template: template,
    );

    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (filePath) => AsyncData(
        PdfExportState(
          exportedFilePath: filePath,
          successMessage: 'PDF exported successfully.',
        ),
      ),
    );
  }

  void clear() {
    state = const AsyncData(PdfExportState());
  }
}

class PdfExportState {
  final String? exportedFilePath;
  final String? successMessage;

  const PdfExportState({
    this.exportedFilePath,
    this.successMessage,
  });

  bool get hasExportedFile =>
      exportedFilePath != null && exportedFilePath!.trim().isNotEmpty;

  bool get hasSuccessMessage =>
      successMessage != null && successMessage!.trim().isNotEmpty;

  PdfExportState copyWith({
    String? exportedFilePath,
    String? successMessage,
    bool clearExportedFilePath = false,
    bool clearSuccessMessage = false,
  }) {
    return PdfExportState(
      exportedFilePath: clearExportedFilePath
          ? null
          : (exportedFilePath ?? this.exportedFilePath),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
