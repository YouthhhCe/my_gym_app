// 路径: lib/core/services/background_timer_handler.dart

import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz; // [!] 1. 导入时区数据

class BackgroundAlarmHandler {
  final ServiceInstance _service;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  BackgroundAlarmHandler(this._service) {
    _service.on('schedule').listen(_handleSchedule);
    _service.on('cancel').listen(_handleCancel);
  }

  Future<void> _handleSchedule(Map<String, dynamic>? data) async {
    final int duration = data?['duration'] as int? ?? 0;
    if (duration <= 0) {
      _service.stopSelf();
      return;
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: duration));

    await _localNotificationsPlugin.zonedSchedule(
      889,
      '休息结束！',
      '准备好开始下一组训练了吗？',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'gym_timer_channel',
          '健身计时器通知',
          importance: Importance.max,
          priority: Priority.high,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    _service.stopSelf();
  }

  Future<void> _handleCancel(Map<String, dynamic>? data) async {
    await _localNotificationsPlugin.cancel(889);
    _service.stopSelf();
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  // [!] 核心修正点 2: 在后台 isolate 中独立初始化
  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  // 初始化时区数据，后台也需要
  tz.initializeTimeZones();

  // 异步初始化
  Future<void> initializePlugins() async {
    await localNotificationsPlugin.initialize(initializationSettings);
    // 初始化完成后，才创建我们的处理器
    BackgroundAlarmHandler(service);
  }

  initializePlugins();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
