# Cloud Function Troubleshooting Guide

## Error: 403 Forbidden

**Problem:** When trying to export a PDF, you see:
```
Export error, export failed: instance of server failure
Cloud Function is not publicly accessible. Please check Firebase Console permissions.
```

**Root Cause:** The Cloud Function requires authentication to be invoked. This is a security setting in Google Cloud.

---

## Solution: Make Cloud Function Publicly Accessible

### Option 1: Using Firebase Console (Recommended for beginners)

1. **Open Firebase Console**
   - Go to https://console.firebase.google.com
   - Select project `resume-labs-cdc63`

2. **Navigate to Cloud Functions**
   - Click **Build** (left sidebar)
   - Select **Functions**
   - Click on `generatePdf` function

3. **Grant Public Access**
   - Click the **Permissions** tab (or **IAM & Admin** in GCP Console)
   - Click **Grant Access** button
   - In "New principals" field, enter: `allUsers`
   - From "Role" dropdown, select: **Cloud Functions → Cloud Functions Invoker**
   - Click **Save**

### Option 2: Using Google Cloud Console (Alternative)

1. **Go to Google Cloud Console**
   - https://console.cloud.google.com
   - Select project `resume-labs-cdc63`

2. **Navigate to Cloud Functions**
   - Click ☰ menu → **Cloud Functions**
   - Click on `generatePdf` function

3. **Update IAM Binding**
   - Click **Permissions** tab
   - Click **Grant Access**
   - Principal: `allUsers`
   - Role: `Cloud Functions Invoker`
   - Click **Save**

### Option 3: Using gcloud CLI (Advanced)

```bash
gcloud functions add-iam-policy-binding generatePdf \
  --region=us-central1 \
  --member=allUsers \
  --role=roles/cloudfunctions.invoker \
  --project=resume-labs-cdc63
```

---

## Verify the Fix

After granting public access, test with:

```bash
curl -X POST https://us-central1-resume-labs-cdc63.cloudfunctions.net/generatePdf \
  -H "Content-Type: application/json" \
  -d '{
    "resumeData": {
      "title": "Test Resume",
      "personalSummary": "Test",
      "workExperiences": [],
      "educations": [],
      "skills": []
    },
    "template": "classic"
  }'
```

**Expected Response:**
- HTTP 200 with binary PDF data (looks like garbage in terminal, which is correct)
- NOT a 403 error

---

## Why the Flutter App Now Includes Firebase Auth

The updated `FirebasePdfService` now:

1. **Attempts unauthenticated access first** (after you grant public permissions)
2. **Falls back to Firebase Auth** if needed (if you keep function private)
3. **Provides clear error messages** for 403 errors

This gives you flexibility:
- **Public function** (easier): Anyone with the URL can generate PDFs
- **Private function** (more secure): Only authenticated users can generate PDFs

---

## Common Issues & Solutions

### "403 Forbidden" still appears after granting access

**Solution:**
1. Wait 2-3 minutes for permissions to propagate
2. Clear Flutter app cache: `flutter clean`
3. Rebuild app: `flutter pub get && flutter run`

### "Cloud Function URL not configured" error

**Solution:**
- Check `.env` file contains: `FIREBASE_PDF_FUNCTION_URL=https://us-central1-resume-labs-cdc63.cloudfunctions.net/generatePdf`
- Rebuild app: `flutter pub get && flutter run`

### Cloud Function times out

**Solution:**
- Timeout is set to 60 seconds
- For very large resumes, try again (first call can be slower due to Puppeteer startup)
- Check Cloud Function logs: `firebase functions:log --project resume-labs-cdc63`

### PDF is generated but not shared

**Solution:**
- Check internet connection
- Try sharing manually instead of automatic share dialog
- Check if PDF is actually being received (look at Flutter logs)

---

## Security Considerations

**Making Cloud Function Public:**
- ✅ **Safe**: Function only accepts POST requests with valid JSON
- ✅ **Rate Limited**: Google Cloud has built-in rate limiting
- ✅ **Costs Control**: Free tier covers ~2M calls/month
- ⚠️ **Potential Risk**: Anyone with URL can generate PDFs (uses your quota)

**If You Want More Security:**

Option 1: Keep function private (users must be authenticated)
- Requires Firebase Auth token in request
- Updated code already handles this
- More complex for users

Option 2: Add API key validation
- Modify Cloud Function to check API key
- Add key to `.env` file
- More work but better security

Option 3: Add Cloud Armor rules
- Restrict by IP/country
- Requires GCP setup

---

## Next Steps

1. ✅ Grant public access to Cloud Function (use one of the three options above)
2. ✅ Wait 2-3 minutes for changes to propagate
3. ✅ Test with curl command
4. ✅ Rebuild Flutter app: `flutter pub get && flutter run`
5. ✅ Test export in the app

---

## Get Help

If you're still having issues:

1. **Check Cloud Function logs:**
   ```bash
   firebase functions:log --project resume-labs-cdc63
   ```

2. **Check deployed function status:**
   ```bash
   firebase functions:list --project resume-labs-cdc63
   ```

3. **Verify function URL:**
   ```bash
   gcloud functions describe generatePdf --region=us-central1 --project=resume-labs-cdc63
   ```

4. **Check Firebase Console:**
   - Go to Cloud Functions → generatePdf
   - Verify status is "ACTIVE" (green checkmark)
   - Verify Trigger shows "HTTPS" with the correct URL
