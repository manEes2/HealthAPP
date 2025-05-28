import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_medium_app/common_widgets/custom_loader.dart';
import 'package:medical_medium_app/services/firebase_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _editing = false;
  bool _isLoading = true;

  Map<String, TextEditingController> controllers = {};

  bool get editing => _editing;
  bool get isLoading => _isLoading;

  Future<void> loadQuestionnaire() async {
    _isLoading = true;
    notifyListeners();

    final data = await _firebaseService.getQuestionnaireData();
    controllers = {
      for (var entry in data.entries)
        entry.key: TextEditingController(text: entry.value.toString())
    };

    _isLoading = false;
    notifyListeners();
  }

  void toggleEdit() {
    _editing = !_editing;
    notifyListeners();
  }

  Future<void> saveQuestionnaire() async {
    final data = {
      for (var entry in controllers.entries) entry.key: entry.value.text
    };
    await _firebaseService.saveQuestionnaire(data);
    toggleEdit(); // Set back to view mode
  }

  Future<void> uploadPhoto(String category, BuildContext context) async {
    final picker = ImagePicker();
    
    // Show dialog to choose between camera and gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Choose photo source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (source == null) return;

    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final file = File(picked.path);
    CustomLoader.show(context, text: "Uploading...");
    final url = await _firebaseService.uploadImage(file, category);
    await _firebaseService.savePhotoMetadata(url, category);
    CustomLoader.hide(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Photo uploaded!')));
  }
}
