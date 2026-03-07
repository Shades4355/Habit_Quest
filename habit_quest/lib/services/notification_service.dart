// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final notificationPlugin = FlutterLocalNotificationsPlugin();

//   bool _isInitialized = false;

//   bool get isInitialized => _isInitialized;

//   // Initialize Notification Service
//   Future<void> initNotification() async {
//     if (_isInitialized) return;

//     // Android initialization
//     const initSettingsAndroid  = AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization
//     const initSettingsIOS = DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );

//     // Initialization settings for both platforms
//     const initSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingsIOS,
//     );

//     // Initialize the plugin
//     await notificationPlugin.initialize(settings: initSettings);
//     _isInitialized = true;
//   }

//   // Notification Setup
//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'daily_reminder_channel',
//         'Daily Reminders',
//         channelDescription: 'Channel for daily habit reminders',
//         importance: Importance.max,
//         priority: Priority.high,  
//       ),
//       iOS: DarwinNotificationDetails()
//     );
//   }
//   // Show Notification
//   Future<void> showNotification({int id = 0, String? title, String? body}) async {
//     await notificationPlugin.show(
//       id: id,
//       title: title ?? 'Reminder: Record Your Habits!',
//       body: body ?? 'Don\'t forget to log your habits for today!',
//       notificationDetails: notificationDetails(),
//     );
//   }
// }