import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Singleton pattern to ensure only one instance of the service exists
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Check if notifications are enabled (Android-specific)
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted || status == PermissionStatus.provisional;
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.status;

    if (status.isGranted || status == PermissionStatus.provisional) {
      return true;
    }

    final result = await Permission.notification.request();
    if (result.isGranted || result == PermissionStatus.provisional) {
      return true;
    }

    // If iOS does not grant in-app, allow user to enable in Settings and re-check.
    if (result.isDenied || result.isPermanentlyDenied || result.isRestricted) {
      await openAppSettings();
      final refreshed = await Permission.notification.status;
      return refreshed.isGranted || refreshed == PermissionStatus.provisional;
    }

    return false;
  }

  /// Initialize Notification Service
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz_data.initializeTimeZones();

    // Android initialization
    const initSettingsAndroid  = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const initSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Initialization settings for both platforms
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // Initialize the plugin
    await notificationPlugin.initialize(settings: initSettings);

    // Only request permission if user has notifications enabled
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('allowDaily') ?? false;
    if (notificationsEnabled && !await areNotificationsEnabled()) {
      await requestPermissions();
    }

    _isInitialized = true;
  }

  /// Notification Setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminders',
        channelDescription: 'Channel for daily habit reminders',
        importance: Importance.max,
        priority: Priority.high,  
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  /// Show a notification
  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    await notificationPlugin.show(
      id: id,
      title: title ?? 'Reminder: Record Your Habits!',
      body: body ?? 'Don\'t forget to log your habits for today!',
      notificationDetails: notificationDetails(),
    );
  }

  /// Schedule a daily notification at a specific time
  Future<void> scheduleDailyNotification({int id = 0, String? title, String? body, required int hour, required int minute}) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    await notificationPlugin.zonedSchedule(
      id: id,
      title: title ?? 'Reminder: Record Your Habits!',
      body: body ?? 'Don\'t forget to log your habits for today!',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Helper to get the next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id: id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
  }
}