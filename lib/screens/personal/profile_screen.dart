import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:health_app/common_widgets/custom_loader.dart';
import 'package:health_app/core/const/app_color.dart';
import 'package:health_app/screens/personal/before_after_photo.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final picker = ImagePicker();
  bool _editing = false;
  Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic> _questionnaireData = {};

  Future<void> _uploadImage(String category) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance.ref().child(
        'users/$userId/photos/$category/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await storageRef.putFile(file);
    final url = await storageRef.getDownloadURL();

    // Show loader
    CustomLoader.show(context, text: "Uploading...");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('photos')
        .add({
      'category': category,
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Hide loader
    CustomLoader.hide(context);
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo uploaded!')),
    );
  }

  Future<void> _loadQuestionnaire() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('questionnaires')
        .doc(userId)
        .get();

    final data = snapshot.data() ?? {};
    _questionnaireData = data;

    _controllers = {
      for (var entry in data.entries)
        entry.key: TextEditingController(text: entry.value.toString())
    };

    setState(() {});
  }

  Future<void> _saveQuestionnaire() async {
    final updatedData = {
      for (var entry in _controllers.entries) entry.key: entry.value.text
    };

    await FirebaseFirestore.instance
        .collection('questionnaires')
        .doc(userId)
        .set(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questionnaire updated!')),
    );

    setState(() {
      _editing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuestionnaire();
  }

  Widget _photoTile(String category, String iconPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BeforeAfterPhotosScreen(category: category),
            ));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Image.asset(iconPath, height: 40),
          title: Text(category),
          trailing: IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => _uploadImage(category),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Besom',
          fontSize: 24,
          color: Colors.brown.shade800,
        ),
      ),
    );
  }

  // Build the questionnaire section
  Widget _buildQuestionnaireSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionHeader("📝 Questionnaire"),
            const Spacer(),
            IconButton(
              icon: Icon(_editing ? Icons.check_circle : Icons.edit),
              color: _editing ? Colors.green : Colors.blueGrey,
              tooltip: _editing ? "Save changes" : "Edit your answers",
              onPressed: () {
                if (_editing) {
                  _saveQuestionnaire();
                } else {
                  setState(() => _editing = true);
                }
              },
            )
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _questionnaireData.isEmpty
              ? Card(
                  key: const ValueKey("no_data"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.red.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No questionnaire data found."),
                  ),
                )
              : Card(
                  key: const ValueKey("data"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: _controllers.entries.map((entry) {
                        IconData icon = Icons.question_answer;
                        if (entry.key.toLowerCase().contains("symptom")) {
                          icon = Icons.sick;
                        } else if (entry.key.toLowerCase().contains("fat")) {
                          icon = Icons.scale;
                        } else if (entry.key.toLowerCase().contains("food")) {
                          icon = Icons.fastfood;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            controller: entry.value,
                            enabled: _editing,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: entry.key,
                              prefixIcon:
                                  Icon(icon, color: Colors.brown.shade300),
                              filled: true,
                              fillColor: _editing
                                  ? Colors.white
                                  : Colors.brown.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: medicalColors['primary'],
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Text("My Profile",
                      style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Besom',
                          color: Colors.brown.shade800)),
                ),
                const SizedBox(height: 20),
                _buildQuestionnaireSection(),
                const SizedBox(height: 20),
                _sectionHeader("🧪 Medical Reports"),
                _photoTile("X-ray", 'assets/icons/xray.png'),
                _photoTile("Blood Test", 'assets/icons/blood_test.png'),
                _sectionHeader("📸 Photographs"),
                _photoTile("Eyes", 'assets/icons/eye.png'),
                _photoTile("Tongue", 'assets/icons/tongue.png'),
                _photoTile("Face", 'assets/icons/face.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
