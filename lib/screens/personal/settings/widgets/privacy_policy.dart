import 'package:flutter/material.dart';
import '../../../../core/const/app_color.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: medicalColors['primary'],
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: medicalColors['primary'],
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('📜 Data Collection & Usage'),
            _buildParagraph(
                'The Medical Medium App collects personal health information to provide personalized wellness recommendations. This includes:'),
            _buildBulletPoint(
                'Health history and symptoms from questionnaires'),
            _buildBulletPoint(
                'Medical reports and diagnostic images you upload'),
            _buildBulletPoint('Progress tracking data'),
            _buildBulletPoint('Account information for authentication'),
            const SizedBox(height: 25),
            _buildSectionTitle('🔒 Data Security'),
            _buildParagraph(
                'We implement industry-standard security measures:'),
            _buildBulletPoint('End-to-end encryption for all health data'),
            _buildBulletPoint('Firebase Authentication for secure access'),
            _buildBulletPoint('Regular security audits of our infrastructure'),
            const SizedBox(height: 25),
            _buildSectionTitle('🖼️ Photo & Media Policy'),
            _buildParagraph('When you upload medical images:'),
            _buildBulletPoint('Images are stored securely in Firebase Storage'),
            _buildBulletPoint('Only used for your personal health tracking'),
            _buildBulletPoint('Never shared without explicit consent'),
            const SizedBox(height: 25),
            _buildSectionTitle('🤝 Third-Party Services'),
            _buildParagraph('We integrate with:'),
            _buildBulletPoint('Firebase for backend services'),
            _buildBulletPoint('Google Gemini AI for protocol generation'),
            _buildBulletPoint('All services comply with HIPAA/GDPR standards'),
            const SizedBox(height: 25),
            _buildSectionTitle('📅 Data Retention'),
            _buildParagraph('Your data is maintained:'),
            _buildBulletPoint('As long as your account remains active'),
            _buildBulletPoint('30 days after account deletion request'),
            _buildBulletPoint('Backups are encrypted and purged quarterly'),
            const SizedBox(height: 25),
            _buildSectionTitle('👥 Your Rights'),
            _buildParagraph('You can:'),
            _buildBulletPoint('Request access to all collected data'),
            _buildBulletPoint('Ask for corrections to inaccurate information'),
            _buildBulletPoint('Delete your account and associated data'),
            _buildBulletPoint(
                'Opt-out of data collection (limits functionality)'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: medicalColors['secondary'],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('I Understand',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
