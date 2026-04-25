import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_labs/core/errors/error_handler.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/datasources/local/hive_adapters.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // `Hive.initFlutter()` uses `path_provider` on iOS. Newer `path_provider`
  // versions use Objective-C FFI which can fail on some simulator runtimes.
  // Fall back to a temp directory instead of crashing on startup.
  try {
    await Hive.initFlutter();
  } catch (e, st) {
    final fallbackDir =
        await Directory.systemTemp.createTemp('resume_labs_hive_');
    Hive.init(fallbackDir.path);
    if (kDebugMode) {
      debugPrint('Hive.initFlutter failed, using temp dir instead.');
      debugPrint('Error: $e');
      debugPrint('$st');
    }
  }
  registerHiveAdapters();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // `.env` is optional in release builds. Sensitive keys should not be
    // bundled inside the app. If present, it can still provide development
    // configuration like FIREBASE_PDF_FUNCTION_URL.
  }

  final firebasePdfFunctionUrl = dotenv.env['FIREBASE_PDF_FUNCTION_URL'];

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    debugPrint(
        'FIREBASE_PDF_FUNCTION_URL loaded: ${firebasePdfFunctionUrl != null}');
    debugPrint('Firebase initialized successfully');
  }

  // final auth = FirebaseAuth.instance;
  // final firestore = FirebaseFirestore.instance;

  ErrorHandler.initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
