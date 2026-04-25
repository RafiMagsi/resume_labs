abstract final class AppStrings {
  static const String appName = 'Resume Labs AI';

  // Firestore collections
  static const String usersCollection = 'users';

  // In-App Purchase
  static const String creditsProductId = 'resume_labs_credits_10';
  static const String creditsPrice = '\$5.99';
  static const String creditsAmount = '10';

  // Generic
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String loading = 'Loading...';
  static const String dismiss = 'Dismiss';

  // Auth
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String forgotPassword = 'Forgot Password?';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String weakPassword = 'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';

  // Errors
  static const String unexpectedError =
      'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your network.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String cacheError = 'Unable to load cached data.';
  static const String authError =
      'Authentication failed. Please check your credentials.';

  // Credits & Paywall
  static const String unlockCredits = 'Buy Resume Optimizations';
  static const String creditsFeature = 'AI-Powered Resume Optimization';
  static const String creditsDescription =
      'Get professional resume recommendations powered by AI';
  static const String buyCredits = 'Buy 10 Optimizations';
  static const String restoreCredits = 'Restore Purchases';
  static const String creditsRemaining = 'Optimizations remaining';
  static const String noCreditsError = 'No credits remaining';
  static const String buyNow = 'Buy Now';
  static const String purchaseSuccess = 'Credits added successfully!';
  static const String purchaseError = 'Failed to complete purchase';
  static const String restoreError = 'Failed to restore purchases';

  // Resume Optimizer
  static const String optimizeResume = 'Optimize Resume with AI';
  static const String pasteYourResume = 'Paste or upload your existing resume';
  static const String optimize = 'Optimize';
  static const String optimizing = 'Optimizing your resume...';
  static const String optimizationSuccess = 'Resume optimized successfully!';
  static const String optimizedResume = 'Optimized Resume';
  static const String originalResume = 'Original Resume';
  static const String copy = 'Copy';
  static const String importToResume = 'Import to Resume';
  static const String createResume = 'Create Resume';
  static const String optimizeAnother = 'Optimize Another Resume';
  static const String resumeTooShort = 'Please enter a longer resume text';
  static const String resumeOptimizationFailed = 'Failed to optimize resume';
}
