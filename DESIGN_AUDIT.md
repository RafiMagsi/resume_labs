# Design Audit: Current vs Reference

**Date:** April 20, 2026  
**Status:** Design Implementation Review

---

## Comparison Summary

### ✅ Complete (No Changes Needed)

| Component | Status | Notes |
|-----------|--------|-------|
| Splash Screen | ✓ | Exists, auto-navigates to login |
| Login Screen | ✓ | Email/password fields, sign in button |
| Register Screen | ✓ | Full name, email, password, confirm password |
| History Screen | ✓ | Lists all user resumes |
| Builder Screen | ✓ | Multi-step form (Personal/Exp/Ed/Skills) |
| Preview Screen | ✓ | Shows resume with template selector |
| AI Suggestion Dialog | ✓ | Shows suggestions with accept/dismiss |
| Error Dialog | ✓ | Shows error with retry button |
| Loading Overlay | ✓ | Shows during PDF/DOCX export |
| Password Reset | ✓ | Email input, send reset link |

---

## ❌ Missing / Needs Update

### Priority 1: Visual Assets (Design Consistency)

#### 1.1 App Logo
- **Status:** ❌ Missing
- **Requirement:** Purple "R" logo in rounded square (shown in reference)
- **Impact:** Splash screen looks incomplete
- **Fix:** Create/add logo asset to `assets/images/`

#### 1.2 Splash Screen Enhancement
- **Status:** ⚠️ Partial (missing logo)
- **Current:** Shows text "Resume Labs" + progress bar
- **Reference:** Shows logo + "Resume Labs" + "Build. Enhance. Succeed."
- **Fix:** Add logo display above/instead of text

---

### Priority 2: Resume History Screen (UX Improvement)

#### 2.1 Resume Card Design
- **Status:** ⚠️ Partial (basic list exists)
- **Current:** Simple list view
- **Reference:** Card-based with:
  - Resume title
  - Template type badge (Modern, Classic, etc.)
  - Last updated timestamp
  - Thumbnail preview
- **Fix:** Enhance card with template badge and better styling

#### 2.2 Resume Card Actions
- **Status:** ❌ Missing
- **Reference:** Options menu (⋯) with: Edit | Delete | Export
- **Current:** No inline actions visible
- **Fix:** Add context menu or action buttons per card

#### 2.3 Search & Filter
- **Status:** ⚠️ Partial (search shown in reference)
- **Current:** No search functionality visible
- **Reference:** Search bar with filter icon
- **Fix:** Add search/filter capability if not implemented

---

### Priority 3: Builder Screen (Form UX)

#### 3.1 Personal Info Photo/Avatar
- **Status:** ❌ Missing
- **Reference:** Circular photo avatar field in personal info section
- **Current:** No photo field in builder
- **Fix:** Add photo picker field to personal info step

#### 3.2 Add Experience Modal
- **Status:** ⚠️ Different approach
- **Reference:** Bottom sheet modal for "Add Experience"
- **Current:** Likely inline form
- **Fix:** Implement bottom sheet for adding/editing work experience

#### 3.3 Step Indicators
- **Status:** ✓ Visible in reference
- **Current:** Should check if visible in current implementation
- **Fix:** Ensure step numbers/tabs are prominent (1, 2, 3, 4)

---

### Priority 4: Register Screen (Validation UX)

#### 4.1 Password Strength Indicator
- **Status:** ❌ Missing
- **Reference:** "At least 8 characters" validation message visible
- **Current:** Not visible in reference comparison
- **Fix:** Add password strength/requirements display

#### 4.2 Confirm Password Validation
- **Status:** ⚠️ Exists but may need visual clarity
- **Reference:** Shows password field with visibility toggle
- **Current:** Visibility toggles should exist
- **Fix:** Ensure both password fields have visibility icons

---

### Priority 5: Color & Typography Consistency

#### 5.1 Verify Color Palette
- **Status:** ⚠️ Need verification
- **Reference Colors:**
  - Primary: Purple (#6D5EF8 or similar)
  - Secondary: Light purple/gray backgrounds
  - Text: Dark gray on light backgrounds
- **Fix:** Review `app_colors.dart` for consistency

#### 5.2 Button Styling
- **Status:** ⚠️ Need verification
- **Reference:** Purple buttons with rounded corners, consistent sizing
- **Fix:** Ensure app_button.dart matches design

---

## Implementation Priority

### Phase 1 (Critical) - 1-2 hours
- [ ] Create/add logo asset
- [ ] Update splash screen to show logo
- [ ] Enhance resume cards with template badge

### Phase 2 (Important) - 2-3 hours
- [ ] Add resume card action menu (edit/delete/export)
- [ ] Add photo field to builder personal info
- [ ] Implement bottom sheet for add experience

### Phase 3 (Polish) - 1-2 hours
- [ ] Add password strength indicator
- [ ] Verify color consistency
- [ ] Add search/filter to history screen

---

## File Changes Required

```
lib/
├── assets/
│   └── images/
│       └── app_logo.svg                    (NEW)
├── presentation/
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart          (UPDATE - add logo)
│   │   ├── history/
│   │   │   └── history_screen.dart         (UPDATE - card actions)
│   │   └── resume_builder/
│   │       └── builder_screen.dart         (UPDATE - photo field, bottom sheets)
│   └── widgets/
│       ├── resume/
│       │   ├── resume_card.dart            (NEW - card with badge)
│       │   ├── add_experience_sheet.dart   (NEW - bottom sheet)
│       │   └── photo_picker.dart           (NEW - avatar picker)
│       └── shared/
│           └── password_strength.dart      (NEW - validation display)
```

---

## Design Notes

**Target Platform:** iOS (mobile)  
**Breakpoint:** Portrait mode (320px-428px width)  
**Typography:** Inter font (already set up)  
**Icons:** Material Icons (via Flutter)  
**State Management:** Riverpod (already set up)  

