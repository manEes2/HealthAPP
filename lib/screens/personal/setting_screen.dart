import 'package:flutter/material.dart';
import 'package:health_app/common_widgets/custom_loader.dart';
import 'package:health_app/core/const/app_color.dart';
import 'package:health_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: medicalColors['primary'],
        body: Stack(
          children: [
            // Background parchment image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.fill,
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Besom',
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Settings options
                    _buildSwitchTile(
                      icon: 'assets/images/notification.png',
                      title: 'Notifications',
                      value: true,
                      onChanged: (val) {},
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationTile(
                      icon: 'assets/images/security.png',
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    // const SizedBox(height: 12),
                    // _buildNavigationTile(
                    //   icon: 'assets/images/theme.png',
                    //   title: 'Theme',
                    //   onTap: () {},
                    // ),

                    const Spacer(),

                    // About App
                    Divider(color: Colors.brown.shade300, thickness: 1),
                    const SizedBox(height: 8),
                    Text(
                      "About This App",
                      style: TextStyle(
                        fontFamily: 'Besom',
                        fontSize: 20,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "This app is designed to support your natural healing journey. "
                      "You can track goals, progress, learn protocols, and grow with a like-minded community.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade800,
                        height: 1.4,
                        fontFamily: 'Besom',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        "v1.0.0",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    // Logout Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          CustomLoader.show(context, text: "Logging out...");
                          await auth.logout();
                          CustomLoader.hide(context);
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        icon: Icon(Icons.logout, color: Colors.brown.shade800),
                        label: Text(
                          "Logout",
                          style: TextStyle(
                            fontFamily: 'Besom',
                            fontSize: 18,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade200,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 32, height: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Besom',
                color: Colors.brown.shade800,
              ),
            ),
          ),
          Switch(
            activeColor: Colors.green.shade700,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.brown.shade200),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 32, height: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Besom',
                  color: Colors.brown.shade800,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.brown.shade300, size: 18),
          ],
        ),
      ),
    );
  }
}
