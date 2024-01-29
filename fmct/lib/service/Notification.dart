// =======================================
// flutter-app 核心模块 - 基于 shared_preferences.dart 的本地数据存储
// 开发者：zbc
// 创建时间：2024-01-29
// 上次维护时间：2024-01-29
// =======================================
// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// ==========================================================================
// ==========================================================================

class Notification {
  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }

  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('--------------------------------notification payload:');
      debugPrint('$payload');
    }
  }

  static Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 初始化
  Future<void> init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin);

    // 初始化 timezone
    await _configureLocalTimeZone();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
  }

  FlutterLocalNotificationsPlugin getInstance() {
    return flutterLocalNotificationsPlugin;
  }

  // 即时通知
  static void show(Notification instance, String title, String content) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    FlutterLocalNotificationsPlugin ninstance = instance.getInstance();
    await ninstance.show(0, title, content, notificationDetails,
        payload: 'item x');
  }

  // 延时通知一次
  static void periodShow(
      Notification instance, String title, String content, int timer) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    FlutterLocalNotificationsPlugin ninstance = instance.getInstance();
    await ninstance.zonedSchedule(
        0,
        title,
        content,
        tz.TZDateTime.now(tz.local).add(Duration(milliseconds: timer)),
        notificationDetails,
        payload: 'item x',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
