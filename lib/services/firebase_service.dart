import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<Map<String, dynamic>> getQuestionnaireData() async {
    final snapshot =
        await _firestore.collection('questionnaires').doc(userId).get();
    return snapshot.data() ?? {};
  }

  Future<void> saveQuestionnaire(Map<String, String> data) async {
    await _firestore.collection('questionnaires').doc(userId).set(data);
  }

  Future<String> uploadImage(File file, String category) async {
    final ref = _storage.ref().child(
        'users/$userId/photos/$category/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> savePhotoMetadata(String url, String category) async {
    await _firestore.collection('users').doc(userId).collection('photos').add({
      'category': category,
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
