import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/core/const/app_color.dart';

class BeforeAfterPhotosScreen extends StatelessWidget {
  final String category;

  const BeforeAfterPhotosScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Photos'),
        backgroundColor: medicalColors['primary'],
      ),
      backgroundColor: medicalColors['primary'],
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('photos')
            .where('category', isEqualTo: category)
            .orderBy('timestamp')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final photos =
              snapshot.data!.docs.map((doc) => doc['url'] as String).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemCount: photos.length,
            itemBuilder: (_, i) => Card(
              child: Image.network(photos[i], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
