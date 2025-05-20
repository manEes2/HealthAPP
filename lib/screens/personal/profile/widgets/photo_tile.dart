import 'package:flutter/material.dart';
import 'package:health_app/screens/personal/profile/widgets/before_after_photo.dart';

class PhotoTile extends StatelessWidget {
  final String category;
  final String iconPath;
  final VoidCallback onUpload;

  const PhotoTile({
    super.key,
    required this.category,
    required this.iconPath,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => BeforeAfterPhotosScreen(category: category)),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Image.asset(iconPath, height: 40),
          title: Text(category),
          trailing: IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: onUpload,
          ),
        ),
      ),
    );
  }
}
