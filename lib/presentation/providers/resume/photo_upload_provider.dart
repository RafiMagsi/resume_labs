import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoUploadProvider = FutureProvider.family<String?, String>(
  (ref, localFilePath) async {
    if (localFilePath.isEmpty) {
      debugPrint('Photo upload: empty path');
      return null;
    }

    try {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('Current user: ${user?.uid}');
      if (user == null) {
        debugPrint('Photo upload: user not authenticated');
        return null;
      }

      final file = File(localFilePath);
      if (!file.existsSync()) {
        debugPrint('Photo upload: file not found at $localFilePath');
        return null;
      }

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final uploadPath = 'profile_photos/${user.uid}/$fileName';
      final ref_ = FirebaseStorage.instance.ref().child(uploadPath);

      debugPrint('Uploading photo to Firebase Storage: $uploadPath');
      await ref_.putFile(file);
      final downloadUrl = await ref_.getDownloadURL();
      debugPrint('Photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      rethrow; // Re-throw to see full error
    }
  },
);
