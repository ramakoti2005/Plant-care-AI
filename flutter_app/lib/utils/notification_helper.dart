import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:js' as js;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize local and web notifications
  static Future<void> initialize() async {
    if (kIsWeb) {
      try {
        js.context.callMethod('requestNotificationPermission');
      } catch (e) {
        debugPrint("Failed to request web notification permission: $e");
      }
      return;
    }

    // Android Settings: Using standard app icon launcher
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/Darwin Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    try {
      await _notificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      debugPrint("Failed to initialize local notifications: $e");
    }
  }

  /// Show a cross-platform push notification
  static Future<void> showNotification(String title, String body) async {
    if (kIsWeb) {
      try {
        js.context.callMethod('showBrowserNotification', [title, body]);
      } catch (e) {
        debugPrint("Failed to show web notification: $e");
      }
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'plant_care_alerts',
      'Plant Care Alerts',
      channelDescription: 'Notifications for plant disease diagnoses and weather risks',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecond, // Safe random ID
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint("Failed to display native push notification: $e");
    }
  }
}
