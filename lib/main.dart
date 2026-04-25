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

  await dotenv.load(fileName: '.env');
  final openAiApiKey = dotenv.env['OPENAI_API_KEY'];
  final firebaseProjectId = dotenv.env['FIREBASE_PROJECT_ID'];
  final firebasePdfFunctionUrl = dotenv.env['FIREBASE_PDF_FUNCTION_URL'];

  assert(
    openAiApiKey != null && openAiApiKey.isNotEmpty,
    'OPENAI_API_KEY is missing in .env',
  );

  assert(
    firebaseProjectId != null && firebaseProjectId.isNotEmpty,
    'FIREBASE_PROJECT_ID is missing in .env',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    debugPrint('OPENAI_API_KEY loaded: ${openAiApiKey != null}');
    debugPrint('FIREBASE_PROJECT_ID loaded: $firebaseProjectId');
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
