import 'package:flutter/material.dart';

class AnimatedLogoLoader {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AnimatedLoaderDialog(),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _AnimatedLoaderDialog extends StatefulWidget {
  const _AnimatedLoaderDialog();

  @override
  State<_AnimatedLoaderDialog> createState() => _AnimatedLoaderDialogState();
}

class _AnimatedLoaderDialogState extends State<_AnimatedLoaderDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scale,
          child: Image.asset(
            'assets/images/heartbeat.png',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}
