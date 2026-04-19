import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../auth/login_screen.dart';
import '../resume_builder/builder_screen.dart';
import '../resume_builder/preview_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const String routeName = 'history';
  static const String routePath = '/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              title: const Text('Senior Flutter Developer Resume'),
              subtitle: const Text('Updated just now'),
              onTap: () => context.push(PreviewScreen.routePath),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(BuilderScreen.routePath),
        child: const Icon(Icons.add),
      ),
    );
  }
}