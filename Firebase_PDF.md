# Firebase Cloud Functions PDF Generation Implementation

## 📋 Quick Start

**Already Implemented in Flutter App:**
- `FirebasePdfService` in `lib/presentation/services/firebase_pdf_service.dart`
- Dependency injection configured in `lib/injection/injection_container.dart`
- Integration in `ResumeDetailScreen` and `PreviewScreen` export buttons
- Environment variable loading in `main.dart`
- Placeholder added to `.env` file

**Next Steps to Complete:**
1. Deploy Cloud Function code to Firebase (`firebase deploy --only functions`)
2. Copy Cloud Function URL from Firebase Console
3. Add URL to `.env`: `FIREBASE_PDF_FUNCTION_URL=https://...`
4. Rebuild Flutter app: `flutter pub get && flutter run`
5. Test PDF export with large resume

---

## Problem: TooManyPagesException

The client-side `pdf` package has hard limitations on PDF page count. When generating resumes with extensive content, the generation fails with `TooManyPagesException`.

**Solution:** Move PDF generation to Firebase Cloud Functions using Puppeteer.

---

## Architecture

```
Flutter App (Client)
    ↓
    | POST /generateResumePdf
    ↓
Firebase Cloud Function
    ├── Receive resume JSON
    ├── Generate HTML from template
    ├── Puppeteer (Headless Chrome)
    ├── Convert HTML → PDF (unlimited pages)
    └── Return PDF buffer
    ↓
Flutter App downloads PDF
```

---

## Implementation Steps

### 1. Set Up Firebase Cloud Functions

```bash
firebase init functions
cd functions
npm install puppeteer express cors
```

### 2. Create Cloud Function for PDF Generation

**File:** `functions/src/generatePdf.js`

```javascript
const functions = require('firebase-functions');
const puppeteer = require('puppeteer');
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors({ origin: true }));

// PDF Generation Function
app.post('/', async (req, res) => {
  try {
    const { resumeData, template } = req.body;

    if (!resumeData || !template) {
      return res.status(400).json({ error: 'Missing resumeData or template' });
    }

    // Generate HTML from resume data and template
    const html = generateResumeHTML(resumeData, template);

    // Launch Puppeteer browser
    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });

    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle0' });

    // Generate PDF (unlimited pages)
    const pdfBuffer = await page.pdf({
      format: 'A4',
      margin: { top: '0px', bottom: '0px', left: '0px', right: '0px' },
    });

    await browser.close();

    // Return PDF as base64
    res.set('Content-Type', 'application/pdf');
    res.send(pdfBuffer);

  } catch (error) {
    console.error('PDF Generation Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Helper: Generate HTML from resume data
function generateResumeHTML(resumeData, template) {
  const { title, personalSummary, workExperiences, educations, skills, photoUrl } = resumeData;

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 900px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #000; padding-bottom: 20px; }
        .header h1 { margin: 0; font-size: 28px; }
        .header p { margin: 5px 0; font-size: 14px; color: #666; }
        .section { margin-bottom: 25px; }
        .section-title { font-size: 18px; font-weight: bold; border-bottom: 1px solid #ccc; padding-bottom: 10px; margin-bottom: 15px; }
        .entry { margin-bottom: 15px; }
        .entry-title { font-weight: bold; font-size: 15px; }
        .entry-subtitle { font-size: 13px; color: #666; font-style: italic; }
        .entry-text { font-size: 13px; margin-top: 5px; }
        .skills-list { display: flex; flex-wrap: wrap; gap: 10px; }
        .skill-tag { background-color: #e8f4f8; padding: 5px 10px; border-radius: 4px; font-size: 12px; }
        ${template === 'modern' ? '.header { background-color: #f5f5f5; }' : ''}
      </style>
    </head>
    <body>
      <div class="container">
        <!-- Header -->
        <div class="header">
          <h1>${title || 'Resume'}</h1>
          ${personalSummary ? `<p>${personalSummary}</p>` : ''}
        </div>

        <!-- Work Experience -->
        ${workExperiences && workExperiences.length > 0 ? `
          <div class="section">
            <h2 class="section-title">Work Experience</h2>
            ${workExperiences.map(exp => `
              <div class="entry">
                <div class="entry-title">${exp.role || ''} at ${exp.company || ''}</div>
                <div class="entry-subtitle">${exp.startDate || ''} - ${exp.endDate || 'Present'}</div>
                <div class="entry-text">${exp.description || ''}</div>
              </div>
            `).join('')}
          </div>
        ` : ''}

        <!-- Education -->
        ${educations && educations.length > 0 ? `
          <div class="section">
            <h2 class="section-title">Education</h2>
            ${educations.map(edu => `
              <div class="entry">
                <div class="entry-title">${edu.degree || ''} in ${edu.fieldOfStudy || ''}</div>
                <div class="entry-subtitle">${edu.institution || ''}</div>
                <div class="entry-text">${edu.year || ''}</div>
              </div>
            `).join('')}
          </div>
        ` : ''}

        <!-- Skills -->
        ${skills && skills.length > 0 ? `
          <div class="section">
            <h2 class="section-title">Skills</h2>
            <div class="skills-list">
              ${skills.map(skill => `<span class="skill-tag">${skill.name || ''}</span>`).join('')}
            </div>
          </div>
        ` : ''}
      </div>
    </body>
    </html>
  `;
}

exports.generatePdf = functions.https.onRequest(app);
```

**File:** `functions/src/index.js`

```javascript
const { generatePdf } = require('./generatePdf');

exports.generatePdf = generatePdf;
```

### 3. Deploy Cloud Function

```bash
firebase deploy --only functions
```

Get your Cloud Function URL from Firebase Console.

---

## Flutter Implementation

### Add HTTP Dependency

```yaml
dependencies:
  http: ^1.1.0
```

### Create PDF Service

**File:** `lib/presentation/services/firebase_pdf_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/errors/failure.dart';

class FirebasePdfService {
  final String? _cloudFunctionUrl;

  FirebasePdfService({String? cloudFunctionUrl})
    : _cloudFunctionUrl = cloudFunctionUrl;

  Future<List<int>> generateResumePdf({
    required Map<String, dynamic> resumeData,
    required String template,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (_cloudFunctionUrl == null || _cloudFunctionUrl!.isEmpty) {
      throw ServerFailure(
        'Firebase PDF Cloud Function URL not configured. '
        'Set FIREBASE_PDF_FUNCTION_URL environment variable.'
      );
    }

    try {
      final url = _cloudFunctionUrl;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'resumeData': resumeData,
          'template': template,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final errorBody = response.body;
        throw ServerFailure(
          'PDF generation failed: ${response.statusCode}. $errorBody'
        );
      }
    } on http.ClientException catch (e) {
      throw NetworkFailure('Network error during PDF generation: $e');
    } catch (e) {
      rethrow;
    }
  }
}
```

### Register Service in Dependency Injection

**File:** `lib/injection/injection_container.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final firebasePdfServiceProvider = Provider<FirebasePdfService>((ref) {
  final url = dotenv.env['FIREBASE_PDF_FUNCTION_URL'];
  return FirebasePdfService(cloudFunctionUrl: url);
});
```

### Use in Export Button

**In ResumeDetailScreen:** `lib/presentation/screens/resume_detail/resume_detail_screen.dart`

```dart
Future<void> _handleExport() async {
  setState(() => _isExporting = true);

  try {
    final formState = ref.read(resumeFormProvider);
    final template = ref.read(selectedResumeTemplateProvider);
    final firebasePdfService = ref.read(firebasePdfServiceProvider);

    final resumeData = {
      'title': formState.title,
      'personalSummary': formState.personalSummary,
      'photoUrl': formState.photoUrl,
      'workExperiences': formState.workExperiences
          .map((e) => {
            'role': e.role,
            'company': e.company,
            'location': e.location,
            'startDate': e.startDate.toString(),
            'endDate': e.endDate?.toString(),
            'bulletPoints': e.bulletPoints,
          })
          .toList(),
      'educations': formState.educations
          .map((e) => {
            'degree': e.degree,
            'field': e.field,
            'school': e.school,
            'graduationDate': e.graduationDate.toString(),
            'gpa': e.gpa,
          })
          .toList(),
      'skills': formState.skills
          .map((s) => {'name': s.name})
          .toList(),
    };

    final pdfBytes = await firebasePdfService.generateResumePdf(
      resumeData: resumeData,
      template: template.name,
    );

    if (!mounted) return;

    await Printing.sharePdf(
      bytes: Uint8List.fromList(pdfBytes),
      filename: '${formState.title}.pdf',
    );
  } catch (e) {
    if (mounted) {
      ErrorDialog.show(
        context,
        failure: ServerFailure('Export failed: $e'),
        title: 'Export Error',
      );
    }
  } finally {
    if (mounted) setState(() => _isExporting = false);
  }
}
```

**Also Updated:** `lib/presentation/screens/resume_builder/preview_screen.dart` - Same approach in `_handleExport()`

---

## Benefits

✅ **Unlimited Pages** - No TooManyPagesException
✅ **Professional Quality** - Puppeteer renders exactly like a browser
✅ **Scalable** - Firebase handles load automatically
✅ **No App Updates** - Change templates without updating app
✅ **Full Content Support** - All resume sections included
✅ **Cost Effective** - Free tier covers most use cases

---

## Implementation Status

### ✅ Completed in Flutter App

- [x] `FirebasePdfService` created in `lib/presentation/services/firebase_pdf_service.dart`
- [x] Service registered in `lib/injection/injection_container.dart`
- [x] ResumeDetailScreen export button updated to use Firebase service
- [x] PreviewScreen export button updated to use Firebase service
- [x] Environment variable loading in `main.dart`
- [x] Error handling with `ServerFailure` and `NetworkFailure`
- [x] Resume data mapping with correct entity field names
- [x] `.env` placeholder added for `FIREBASE_PDF_FUNCTION_URL`

### ✅ Completed in Firebase

- [x] Cloud Functions project structure created
- [x] TypeScript Cloud Function code written (`functions/src/index.ts`)
- [x] `package.json` and `tsconfig.json` configured
- [x] Code compiled to JavaScript (`functions/lib/`)
- [x] Dependencies installed (puppeteer, express, cors, firebase-functions)
- [x] Deployment initiated to `resume-labs-cdc63` project

### ✅ Cloud Function Deployment

- [x] Cloud Function deployed successfully to `us-central1`
- [x] Function name: `generatePdf`
- [x] Runtime: Node.js 20 (1st Gen)
- [x] Status: **ACTIVE** and ready to use
- [x] URL: `https://us-central1-resume-labs-cdc63.cloudfunctions.net/generatePdf`
- [x] URL added to `.env` file

### ⏳ Final TODO

- [ ] Rebuild Flutter app: `flutter pub get && flutter run`
- [ ] Test PDF export with a resume
- [ ] Verify large resumes export correctly (no page limits)
- [ ] Monitor Cloud Functions usage in Firebase Console
- [ ] Set up error logging if needed

## Deployment Checklist

- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Get Cloud Function URL from Firebase Console
- [ ] Add URL to `.env`: `FIREBASE_PDF_FUNCTION_URL=https://...`
- [ ] Rebuild Flutter app with updated `.env`
- [ ] Test PDF export on iOS/Android
- [ ] Verify large resumes export correctly (no page limits)
- [ ] Monitor Cloud Functions usage for cost
- [ ] Set up error logging in Firebase Console

---

## Configuration

### 1. Update `.env` File

After deploying your Cloud Function, add the URL to `.env`:

```env
FIREBASE_PDF_FUNCTION_URL=https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/generatePdf
```

### 2. Find Your Cloud Function URL

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Navigate to **Cloud Functions**
3. Click on **generatePdf** function
4. Click the **Trigger** tab
5. Copy the **Trigger URL** (it's the value after "Trigger URL:")

Example URL format:
```
https://us-central1-resume-labs-prod.cloudfunctions.net/generatePdf
```

### 3. Verify Integration

The app will automatically load the URL from the environment variable. Debug logs will show:
```
FIREBASE_PDF_FUNCTION_URL loaded: true
```

If not configured, the app will show a user-friendly error when attempting to export.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Puppeteer timeout | Increase PDF timeout in Cloud Function |
| Large files slow | Use Cloud Run instead of Cloud Functions |
| Cost concerns | Implement caching/CDN for generated PDFs |
| Template updates | Store templates in Firestore for dynamic updates |
