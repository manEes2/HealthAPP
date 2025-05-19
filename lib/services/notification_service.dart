import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationsPlugins = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return; // Check if already initialized
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await notificationsPlugins.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        // Handle notification response
      },
    );
  }

  //Notification detail
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Remainders',
        channelDescription: 'Daily remainders Channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  //show notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationsPlugins.show(
      id,
      title,
      body,
      notificationDetails(),
    );
  }

  //schedule notification
}
