# Firebase Cloud Function Deployment Guide

## Status: Deployment In Progress ⏳

Cloud Function `generatePdf` is currently being deployed to Firebase project `resume-labs-cdc63` in the `us-central1` region.

Estimated time remaining: 3-8 minutes

---

## What's Being Deployed

**Cloud Function:** `generatePdf`
- **Language:** TypeScript (compiled to Node.js 20)
- **Runtime:** 512MB memory, 60 second timeout
- **Purpose:** Generate PDF resumes with unlimited pages using Puppeteer
- **Trigger:** HTTP endpoint (accessible from Flutter app)

### Function Features:
- Accepts resume data as JSON
- Generates professional HTML from template
- Uses Puppeteer for browser-based PDF generation
- Returns PDF as binary file
- Supports multiple templates (classic, modern, etc.)
- Error handling with detailed messages

---

## How to Monitor Deployment

### Option 1: Firebase Console (Recommended)
1. Visit https://console.firebase.google.com
2. Select project: `resume-labs-cdc63`
3. Go to **Build → Functions**
4. Look for `generatePdf` function
5. Check status:
   - 🟡 DEPLOYING - Still building
   - 🟢 ACTIVE - Ready to use
   - 🔴 ERROR - Check build logs

### Option 2: Firebase CLI
```bash
firebase functions:log --project resume-labs-cdc63
```

### Option 3: Check Logs in Google Cloud Console
1. Go to https://console.cloud.google.com
2. Select `resume-labs-cdc63`
3. Go to **Cloud Build → History**
4. Find the latest build for `generatePdf`
5. Check build status and logs

---

## After Deployment Completes ✅

### Step 1: Get the Cloud Function URL

**From Firebase Console:**
1. Go to Cloud Functions → `generatePdf`
2. Click the function name
3. Click **Trigger** tab
4. Copy the **Trigger URL**

Example URL:
```
https://us-central1-resume-labs-cdc63.cloudfunctions.net/generatePdf
```

### Step 2: Update `.env` File

Add the Cloud Function URL to your `.env`:

```env
OPENAI_API_KEY=sk-proj-...
FIREBASE_PROJECT_ID=resume-labs-cdc63
FIREBASE_PDF_FUNCTION_URL=https://us-central1-resume-labs-cdc63.cloudfunctions.net/generatePdf
```

### Step 3: Rebuild Flutter App

```bash
# Update dependencies
flutter pub get

# Run the app
flutter run

# Or build for distribution
flutter build apk
flutter build ios
```

### Step 4: Test Export Functionality

1. Open the app
2. Create or open a resume
3. Go to Resume Detail screen (tap a resume card)
4. Click **Export** button
5. Try to share the PDF

**Expected Result:**
- Loading spinner appears
- PDF is generated on Firebase (no page limits!)
- Share dialog opens
- You can save/share the PDF

---

## Troubleshooting

### "FIREBASE_PDF_FUNCTION_URL not configured" Error

**Solution:** Make sure `.env` file has the URL set:
```bash
# Check .env
cat .env | grep FIREBASE_PDF_FUNCTION_URL

# Should show something like:
# FIREBASE_PDF_FUNCTION_URL=https://us-central1-...
```

### "Timeout" Error During Export

**Possible causes:**
- Cloud Function is still deploying (wait for ACTIVE status)
- Network connectivity issue
- PDF is extremely large (will still work, just takes longer)

**Solution:**
1. Check Firebase Console - function must be ACTIVE
2. Check internet connection
3. Try again with a smaller resume first

### "Cloud Function URL not found"

**Solution:**
1. Go to Firebase Console
2. Verify project is `resume-labs-cdc63`
3. Check Cloud Functions section
4. `generatePdf` must exist and be ACTIVE
5. If missing, deployment failed - check build logs

---

## Files Structure

```
/functions/
├── src/
│   └── index.ts              # Main Cloud Function code
├── lib/
│   ├── index.js              # Compiled JavaScript
│   └── index.js.map          # Source map
├── package.json              # Dependencies
├── tsconfig.json             # TypeScript config
└── node_modules/             # Installed packages

/.env
├── OPENAI_API_KEY            # Already configured ✅
├── FIREBASE_PROJECT_ID       # Already configured ✅
└── FIREBASE_PDF_FUNCTION_URL # To be added ⏳

/lib/presentation/services/
└── firebase_pdf_service.dart # Flutter client service ✅

/lib/injection/
└── injection_container.dart  # DI setup ✅
```

---

## Cost Considerations

**Firebase Cloud Functions Pricing:**
- Free tier: 2M invocations/month
- Pay-as-you-go after free tier
- Each PDF export = 1 function invocation

**Estimated costs:**
- 100 PDFs/month: FREE (within free tier)
- 1,000 PDFs/month: ~$0.25-0.50
- 10,000 PDFs/month: ~$2.50-5.00

**Storage considerations:**
- PDF generation uses temporary disk space
- Typically <50MB per function execution
- No persistent storage of PDFs (they're streamed to client)

---

## Next Steps

1. ⏳ **Wait for deployment to complete** (check Firebase Console)
2. ✅ **Copy Cloud Function URL**
3. ✅ **Add URL to `.env` file**
4. ✅ **Rebuild Flutter app**
5. ✅ **Test export with a resume**
6. ✅ **Verify large resumes export without errors**

---

## Support

If deployment fails:
1. Check Firebase Console build logs
2. Common issues:
   - API not enabled (Cloud Build, Cloud Functions, Artifact Registry)
   - Service account permissions
   - Storage bucket access
3. Contact Google Cloud Support if needed

For app issues after deployment:
- Check `firebase functions:log` for server errors
- Enable debug logs in Flutter: `flutter run -v`
- Check `.env` file is correctly configured
