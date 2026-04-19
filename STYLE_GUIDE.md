Resume Labs — Flutter Style Guide

Project: Resume Labs
Platform: Flutter (iOS-first visual direction, Android-compatible)
Design Reference: Apple iOS productivity apps as the primary reference, with Notion Calendar as the secondary product-quality reference.
Theme Direction: Modern, calm, premium, minimal, light-first

⸻

1. Design Principles

1.1 Product feel

Resume Labs should feel like a serious, polished productivity app.

Core traits:

* calm
* premium
* readable
* native-feeling
* minimal, not empty
* modern, not flashy

1.2 Visual direction

Use an iOS-inspired design language with:

* soft rounded corners
* restrained shadows
* high whitespace
* one strong brand color
* layered light surfaces
* strong typography hierarchy
* subtle borders instead of heavy elevation

1.3 Avoid

Do not turn the app into:

* a gradient-heavy SaaS dashboard
* a neon AI app
* a Dribbble fantasy concept
* a crypto-style interface
* a cluttered enterprise CRUD panel

⸻

2. Reference Sources

2.1 Primary reference

Apple iOS Human Interface Guidelines

Used for:

* screen structure
* large titles
* sheets and dialogs
* spacing rhythm
* list behavior
* interaction clarity
* calm visual hierarchy

2.2 Secondary reference

Notion Calendar

Used for:

* premium productivity-app polish
* clean cards
* soft surfaces
* lightweight elegance
* modern light-mode visual balance

2.3 Product interpretation

Resume Labs should look like:
Apple-first productivity UI with Notion-level polish

⸻

3. Design Language Summary

3.1 Core style keywords

* light
* soft
* structured
* premium
* editorial
* focused
* professional

3.2 Visual rules

* backgrounds should be very light gray, not flat white everywhere
* cards should be white with subtle border and soft shadow
* buttons should be clean and strong, not oversized
* forms should feel simple and trustworthy
* AI actions should appear secondary, not dominate the interface
* typography should do more work than decoration

⸻

4. Color System

4.1 Brand colors

class AppColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5B4DD8);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primarySoft = Color(0xFFF5F3FF);
}

Usage:

* primary: main CTA buttons, active stepper, brand highlights
* primaryDark: pressed states or stronger emphasis
* primaryLight: selected chips, soft backgrounds
* primarySoft: AI hint areas, subtle decorative backgrounds

4.2 Background colors

class AppColors {
  static const Color appBackground = Color(0xFFF5F5F7);
  static const Color screenSurface = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFF8F8FA);
  static const Color modalOverlay = Color(0xFF8D919B);
}

Usage:

* appBackground: app scaffold background
* screenSurface: cards, forms, main containers
* secondarySurface: subtle grouped blocks or inactive fills
* modalOverlay: base tone behind dialogs and overlays

4.3 Text colors

class AppColors {
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}

Usage:

* textPrimary: titles, important labels
* textSecondary: descriptions, metadata, helper text
* textTertiary: placeholders, passive UI labels
* textOnPrimary: text on purple buttons and active surfaces

4.4 Borders and dividers

class AppColors {
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEBEDF0);
  static const Color inactive = Color(0xFFD1D5DB);
}

Usage:

* border: input borders, card outlines
* divider: separators
* inactive: stepper inactive elements, disabled visual states

4.5 Semantic colors

class AppColors {
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
}

Usage:

* error: destructive actions, failure emphasis
* errorSoft: dialog icon backgrounds
* success: success states and confirmations
* warning: caution states

4.6 Utility colors

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
}

⸻

5. Transparency and Overlay Rules

5.1 Modal barrier

Use a dark overlay around 60% opacity.

const Color modalBarrier = Color(0x990F172A);

5.2 Shadow opacity

Keep shadows subtle.

Recommended shadow alpha:

* 6% to 10% for cards
* 10% to 14% for dialogs

Example:

BoxShadow(
  color: const Color(0x14000000),
  blurRadius: 24,
  offset: const Offset(0, 8),
)

5.3 Avoid

* opaque overlays that feel heavy
* intense colored glows
* blurry neon shadows

⸻

6. Typography

6.1 Font family

Preferred:

* Inter for Flutter consistency across platforms

Alternative:

* SF Pro if you intentionally align harder to native iOS and manage platform differences carefully

6.2 Type scale

class AppTextSizes {
  static const double displayLarge = 34;
  static const double headlineLarge = 28;
  static const double headlineMedium = 24;
  static const double titleLarge = 20;
  static const double titleMedium = 18;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double caption = 11;
}

6.3 Weights

* w700: major screen headings
* w600: section titles, buttons, strong list titles
* w500: labels, medium emphasis
* w400: standard body copy

6.4 Usage map

Large screen title

* Size: 28
* Weight: 700
* Color: textPrimary

Section title

* Size: 20
* Weight: 700 or 600
* Color: textPrimary

Card title

* Size: 16
* Weight: 600
* Color: textPrimary

Body text

* Size: 14
* Weight: 400
* Color: textSecondary

Input label

* Size: 12
* Weight: 500
* Color: textPrimary

Button text

* Size: 15–16
* Weight: 600
* Color: based on surface

⸻

7. Spacing System

Use a 4-based spacing rhythm.

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double sectionGap = 40;
}

7.1 Common layout usage

* screen horizontal padding: 20
* card padding: 16–20
* vertical gap between inputs: 12–16
* gap between sections: 24–32
* large hero/top spacing: 24–32

7.2 Rules

* do not compress forms tightly
* let cards breathe
* use spacing to separate concepts, not extra dividers everywhere

⸻

8. Corner Radius System

class AppRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 999;
}

8.1 Usage

* text fields: 10–12
* buttons: 10–12
* cards: 16
* dialogs: 20–24
* bottom sheets: 24 top radius
* chips: pill radius

⸻

9. Border System

class AppBorders {
  static const double thin = 1.0;
  static const double medium = 1.2;
  static const double strong = 1.5;
}

9.1 Usage

* inputs: 1
* cards: 1
* stepper inactive circles: 1
* dividers: 1

⸻

10. Shadow System

10.1 Card shadow

const BoxShadow(
  color: Color(0x12000000),
  blurRadius: 18,
  offset: Offset(0, 6),
)

10.2 Dialog shadow

const BoxShadow(
  color: Color(0x18000000),
  blurRadius: 28,
  offset: Offset(0, 10),
)

10.3 Rules

* prefer border + soft shadow together
* never use aggressive elevation
* avoid colored shadow treatments

⸻

11. Component Guidelines

11.1 Scaffold

* Background: appBackground
* Always respect SafeArea
* Content should feel centered and balanced on iPhone

11.2 Buttons

Primary button

* Height: 48
* Radius: 10
* Background: primary
* Text: white
* Font: 15–16, weight 600

Secondary button

* Height: 48
* Radius: 10
* Background: white
* Border: border
* Text: textPrimary

Text button

* No fill
* Purple or muted emphasis
* Font size: 13–14

Disabled button

* Disabled while loading
* Lighter purple or muted background
* Lower contrast but still readable

11.3 Text fields

* Height: 44–48
* Radius: 10–12
* Border: 1px border
* Fill: white
* Horizontal padding: 12
* Label above field
* Hint in tertiary text color

Focus state

* Border color: primary
* Optional extremely subtle highlight shadow

11.4 Cards

* White background
* Radius: 16
* Border: 1px border
* Soft shadow
* Padding: 16–20

11.5 Search bar

* Height: 40
* Radius: 10
* Fill: secondarySurface
* Light icon on left
* No heavy outline

11.6 Stepper

Step circle

* Size: 24
* Active background: primary
* Inactive background: white
* Inactive border: inactive

Step label

* Size: 11
* Active: primary
* Inactive: textSecondary

Connector line

* Height: 2
* Active: primary or primaryLight
* Inactive: border

11.7 Dialogs

* Width: roughly 320–360 on phone
* Radius: 20–24
* White surface
* Centered icon or title block
* Retry and Dismiss actions clearly separated

11.8 Loading overlay

* Full-screen dark translucent overlay
* Centered white card
* Card radius: 20
* Spinner + short status line

11.9 Bottom sheets

* White background
* Top radius: 24
* Drag handle centered
* Padding: 20
* CTA button at bottom with enough spacing

11.10 Resume preview paper

* Paper color: white
* Very light border
* Soft shadow
* A4 ratio feel
* Internal padding: 20–28

⸻

12. Iconography

12.1 Icon style

* thin to medium stroke
* minimal filled icons
* productivity-focused, not decorative

12.2 Sizes

* small inline: 16
* standard trailing: 20
* action icon: 22–24
* large illustration icon: 48–72

12.3 Colors

* default: textSecondary
* active: primary
* destructive: error

⸻

13. Screen-by-Screen Guidance

13.1 Splash Screen

* very minimal composition
* centered logo
* wordmark under logo
* short brand tagline below
* progress line near bottom-middle section

Progress bar

* Width: 132
* Height: 4
* Radius: pill
* Track: primaryLight
* Fill: primary

13.2 Login Screen

* large title near top-left area
* subtitle below
* centered card-style form section
* two input fields
* primary CTA
* secondary CTA
* footer legal/support links in tiny muted text

13.3 Register Screen

* same structure as login
* includes confirm password
* show small password hint line if needed

13.4 History Screen

* large title: “My Resumes”
* search bar below
* stacked resume cards
* metadata row with modified date and template
* trailing action menu
* FAB or primary create action visible

13.5 Builder Screen

* stepper on top
* form below in section card(s)
* preview visible alongside or below depending on width
* sticky bottom actions for Back / Next / Save
* AI actions visually secondary

13.6 AI Suggestion Dialog

* centered or sheet-style presentation
* sparkle/AI icon
* suggestion text in a contained block
* Accept and Dismiss buttons

13.7 Preview Screen

* title and controls at top
* template selector card
* centered resume preview paper
* strong export CTA
* secondary back-to-edit CTA

13.8 Password Reset Screen

* simple single-purpose layout
* illustration/icon block
* heading + one email field + one button

13.9 Error Dialog

* centered error icon in soft red circle
* concise title
* friendly message
* Retry and Dismiss actions

13.10 Loading Overlay

* dimmed background
* centered card
* spinner + short explanatory text

⸻

14. Flutter Theme Mapping

14.1 Base theme

ThemeData(
  scaffoldBackgroundColor: AppColors.appBackground,
  primaryColor: AppColors.primary,
  cardColor: AppColors.screenSurface,
  dividerColor: AppColors.divider,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
)

14.2 Input decoration theme

InputDecorationTheme(
  filled: true,
  fillColor: AppColors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.primary),
  ),
)

14.3 Elevated button theme

ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 0,
  ),
)

14.4 Card theme

CardThemeData(
  color: AppColors.screenSurface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: AppColors.border),
  ),
)

⸻

15. Recommended Token Files

15.1 app_colors.dart

Store all color definitions here.

15.2 app_sizes.dart

Recommended minimum constants:

class AppSizes {
  static const double buttonHeight = 48;
  static const double inputHeight = 46;
  static const double cardRadius = 16;
  static const double dialogRadius = 20;
  static const double screenPadding = 20;
  static const double sectionGap = 24;
}

15.3 app_text_styles.dart

Recommended to add if not already present.

⸻

16. Interaction Rules

Do

* disable buttons while loading
* keep success/failure messaging short and clear
* use dialogs for important failure recovery
* use sheets for add/edit forms
* use pull-to-refresh where data lists matter

Do not

* expose raw exception strings to users
* navigate unpredictably
* make AI buttons feel more important than core form actions
* over-animate business-critical flows

⸻

17. Accessibility Rules

* Minimum readable body text: 12
* Target normal body size: 14
* Maintain strong color contrast
* Labels must be clear and visible
* Inputs and buttons must have comfortable tap targets
* Do not rely only on color for error states

⸻

18. Final Product Intent

Resume Labs should visually communicate:

* trust
* clarity
* speed
* professionalism
* craftsmanship

The design should feel like a polished native productivity app, not a noisy AI demo.

⸻

19. Final Recommendation

Use Apple iOS productivity design language as the base, with Notion Calendar-level polish.

That is the visual reference and standard this project should follow.