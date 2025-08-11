// 路径: lib/core/services/notification_service.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

/// 一个封装了所有通知和后台服务逻辑的类
class NotificationService {
  // --- 私有常量 ---
  static const String _notificationChannelId = 'gym_timer_channel';
  static const String _notificationChannelName = '健身计时器通知';
  static const String _notificationChannelDescription = '用于显示组间休息结束的通知';
  static const int _foregroundServiceNotificationId = 888;
  static const int _restFinishedNotificationId = 889;

  /// 全局的本地通知插件单例
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 后台服务单例
  static final FlutterBackgroundService _backgroundService =
      FlutterBackgroundService();

  /// 静态方法：初始化服务
  static Future<void> initialize() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.max,
      playSound: false,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        // 这里可以设置一个更通用的标题，因为它不会再变化
        initialNotificationTitle: '健身伴侣',
        initialNotificationContent: '组间休息计时中...',
        foregroundServiceNotificationId: _foregroundServiceNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  /// 静态方法：启动计时器
  static void startTimer({required int duration}) {
    _backgroundService.startService();
    _backgroundService.invoke('startTimer', {'duration': duration});
  }

  /// 静态方法：停止服务
  static void stopService() {
    _backgroundService.invoke('stopService');
  }
}

// --- 后台隔离区的入口点 ---

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  Timer? restTimer;

  service.on('startTimer').listen((data) {
    restTimer?.cancel();
    final int durationInSeconds = (data?['duration'] as int?) ?? 0;

    if (durationInSeconds <= 0) return;

    int currentSeconds = durationInSeconds;

    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // 计时器仍然在后台精确运行
      currentSeconds--;

      // *******************************************************************
      // 我们已经将 setForegroundNotificationInfo(...) 这一行彻底删除！
      // 不再有实时的通知更新，也不会再有那个编译错误。
      // *******************************************************************

      if (currentSeconds <= 0) {
        restTimer?.cancel();

        // 倒计时结束，触发振动
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(pattern: [0, 500, 200, 500]);
        }

        // 倒计时结束，弹出“完成”通知
        NotificationService._localNotificationsPlugin.show(
          NotificationService._restFinishedNotificationId,
          '休息结束！',
          '准备好开始下一组训练了吗？',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationService._notificationChannelId,
              NotificationService._notificationChannelName,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true),
          ),
        );
        service.stopSelf();
      }
    });
  });

  service.on('stopService').listen((event) {
    restTimer?.cancel();
    service.stopSelf();
  });
}
