Storing image files directly in Cloud Firestore as binary data is generally discouraged because of the 1 MB limit per document. 
Stack Overflow
Stack Overflow
 +1
Instead, the standard "best practice" for Flutter and Firebase is to:
Upload the image file to Firebase Cloud Storage.
Retrieve the public Download URL of that image.
Store that URL string inside your Firestore document. 
Reddit
Reddit
 +4
Step-by-Step Flutter Implementation
1. Upload Image to Cloud Storage 
Use the firebase_storage package to upload the file and get its URL. 
dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> uploadImage(File imageFile) async {
  try {
    // Create a unique filename
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create a reference to the storage location
    Reference ref = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
    
    // Upload the file
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    
    // Get the public download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print("Error uploading: $e");
    return null;
  }
}
Use code with caution.
2. Save the URL in Firestore 
Once you have the downloadUrl, save it to your desired collection. 
Stack Overflow
Stack Overflow
dart
Future<void> saveImageUrlToFirestore(String url) async {
  await FirebaseFirestore.instance.collection('users').add({
    'profile_pic': url,
    'uploaded_at': FieldValue.serverTimestamp(),
  });
}
Use code with caution.
Why use this method?
Scalability: Firebase Storage is designed for large files (GBs), whereas Firestore is optimized for small, fast JSON data.
Cost: Storing binary data in Firestore is much more expensive than using Cloud Storage.
Performance: Loading a URL directly into an Image.network() widget is faster and keeps your Firestore documents lightweight. 
Stack Overflow
Stack Overflow
 +3
Important: Remember to update your Firebase Storage Rules to allow your app to read and write files. 
