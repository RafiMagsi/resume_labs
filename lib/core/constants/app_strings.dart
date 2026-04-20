abstract final class AppStrings {
  static const String appName = 'Resume Labs AI';

  // Firestore collections
  static const String usersCollection = 'users';

  // In-App Purchase
  static const String premiumProductId = 'resume_labs_premium';

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

  // Paywall
  static const String unlockPremium = 'Unlock Premium';
  static const String premiumFeatures = 'Premium Features';
  static const String allTemplates = 'All 6 Professional Templates';
  static const String aiContentGeneration = 'AI-powered content generation';
  static const String unlimitedResumes = 'Unlimited resumes';
  static const String oneTimePurchase = 'One-time purchase, forever';
  static const String upgradeToPremium = 'Upgrade to Premium';
  static const String restorePurchase = 'Restore Purchase';
  static const String purchaseSuccess = 'Welcome to Premium!';
  static const String purchaseError = 'Failed to complete purchase';
  static const String restoreError = 'Failed to restore purchases';
}
