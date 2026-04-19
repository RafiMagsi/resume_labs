import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'preview_screen.dart';

class BuilderScreen extends StatelessWidget {
  const BuilderScreen({super.key});

  static const String routeName = 'builder';
  static const String routePath = '/builder';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
      ),
      body: const Center(
        child: Text('Builder Screen'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => context.push(PreviewScreen.routePath),
          child: const Text('Preview Resume'),
        ),
      ),
    );
  }
}