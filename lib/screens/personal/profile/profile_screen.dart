import 'package:flutter/material.dart';
import 'package:health_app/core/const/app_color.dart';
import 'package:health_app/screens/personal/profile/provider/profile_provider.dart';
import 'package:health_app/screens/personal/profile/widgets/photo_tile.dart';
import 'package:health_app/screens/personal/profile/widgets/questionnaire_section.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..loadQuestionnaire(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: medicalColors['primary'],
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/images/background.png',
                      fit: BoxFit.cover),
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
                      QuestionnaireSection(
                        controllers: provider.controllers,
                        editing: provider.editing,
                        onToggleEdit: () {
                          if (provider.editing) {
                            provider.saveQuestionnaire();
                          } else {
                            provider.toggleEdit();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _sectionHeader("🧪 Medical Reports"),
                      PhotoTile(
                          category: "X-ray",
                          iconPath: 'assets/icons/xray.png',
                          onUpload: () =>
                              provider.uploadPhoto("X-ray", context)),
                      PhotoTile(
                          category: "Blood Test",
                          iconPath: 'assets/icons/blood_test.png',
                          onUpload: () =>
                              provider.uploadPhoto("Blood Test", context)),
                      _sectionHeader("📸 Photographs"),
                      PhotoTile(
                          category: "Eyes",
                          iconPath: 'assets/icons/eye.png',
                          onUpload: () =>
                              provider.uploadPhoto("Eyes", context)),
                      PhotoTile(
                          category: "Tongue",
                          iconPath: 'assets/icons/tongue.png',
                          onUpload: () =>
                              provider.uploadPhoto("Tongue", context)),
                      PhotoTile(
                          category: "Face",
                          iconPath: 'assets/icons/face.png',
                          onUpload: () =>
                              provider.uploadPhoto("Face", context)),
                    ],
                  ),
                ),
              ],
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
}
