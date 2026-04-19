import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_sizes.dart';
import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Resume Labs AI',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          surface: AppColors.screenSurface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.appBackground,
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        dividerColor: AppColors.divider,
        textTheme: Typography.blackCupertino
            .copyWith(
              displayLarge: const TextStyle(
                fontSize: AppTextSizes.displayLarge,
                fontWeight: FontWeight.w700,
              ),
              headlineLarge: const TextStyle(
                fontSize: AppTextSizes.headlineLarge,
                fontWeight: FontWeight.w700,
              ),
              headlineMedium: const TextStyle(
                fontSize: AppTextSizes.headlineMedium,
                fontWeight: FontWeight.w700,
              ),
              titleLarge: const TextStyle(
                fontSize: AppTextSizes.titleLarge,
                fontWeight: FontWeight.w700,
              ),
              titleMedium: const TextStyle(
                fontSize: AppTextSizes.titleMedium,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: const TextStyle(
                fontSize: AppTextSizes.bodyLarge,
              ),
              bodyMedium: const TextStyle(
                fontSize: AppTextSizes.bodyMedium,
              ),
              bodySmall: const TextStyle(
                fontSize: AppTextSizes.bodySmall,
              ),
              labelSmall: const TextStyle(
                fontSize: AppTextSizes.caption,
              ),
            )
            .apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          hintStyle: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: AppTextSizes.bodyMedium,
          ),
          labelStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppTextSizes.bodySmall,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, AppSizes.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.screenSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.screenSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
