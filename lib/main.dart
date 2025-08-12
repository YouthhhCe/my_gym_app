// 路径: lib/main.dart

import 'package:flutter/material.dart';
import 'package:my_gym_app/app/widgets/main_scaffold.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_gym_app/core/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化时区数据库，为精确闹钟做准备
  tz.initializeTimeZones();

  // 初始化国际化日期格式
  await initializeDateFormatting('zh_CN', null);

  // 检查并请求通知权限
  await Permission.notification.request();

  // 在Android上，精确闹钟也需要特殊权限
  await Permission.scheduleExactAlarm.request();

  // 初始化我们的通知服务
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健身伴侣',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        fontFamily: 'Inter',
      ),
      home: const MainScaffold(),
    );
  }
}
