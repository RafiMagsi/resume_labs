import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_labs/core/errors/error_handler.dart';
import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  final openAiApiKey = dotenv.env['OPENAI_API_KEY'];
  final firebaseProjectId = dotenv.env['FIREBASE_PROJECT_ID'];
  
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
