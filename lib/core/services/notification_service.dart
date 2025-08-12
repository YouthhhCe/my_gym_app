// 路径: lib/core/services/notification_service.dart

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_gym_app/core/services/background_timer_handler.dart';

class NotificationService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // [!] 核心修正点 1: 在这里统一初始化通知插件
    // 这是主isolate的初始化
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // 使用app图标
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _localNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'gym_timer_channel',
      '健身计时器通知',
      description: '用于显示组间休息结束的通知',
      importance: Importance.max,
      playSound: false,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'gym_timer_channel',
        initialNotificationTitle: '健身伴侣',
        initialNotificationContent: '正在设定休息提醒...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<void> scheduleTimer({required int duration}) async {
    if (!await _service.isRunning()) {
      await _service.startService();
    }
    _service.invoke('schedule', {'duration': duration});
  }

  static Future<void> cancelTimer() async {
    // 即使服务可能不在运行，取消操作也应该尝试启动服务来执行
    if (!await _service.isRunning()) {
      await _service.startService();
    }
    _service.invoke('cancel');
  }
}
