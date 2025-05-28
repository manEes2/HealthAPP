import 'package:flutter/material.dart';
import 'package:medical_medium_app/core/const/app_color.dart';

class CustomLoader {
  static void show(BuildContext context, {String text = "Loading..."}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        child: Dialog(
          backgroundColor: medicalColors['primary'],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/bee.png", width: 100, height: 100),
                const SizedBox(height: 16),
                CircularProgressIndicator(color: Colors.green),
                const SizedBox(height: 16),
                Text(text,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Besom')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
