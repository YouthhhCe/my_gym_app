// 路径: lib/main.dart (修改后)

import 'package:flutter/material.dart';
import 'package:my_gym_app/app/widgets/main_scaffold.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_gym_app/core/services/notification_service.dart'; // [!] 保持这个导入

// [!] 不再需要导入 flutter_local_notifications

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // [!] flutterLocalNotificationsPlugin.initialize(...) 这段代码已移入 NotificationService，此处不再需要。

  await initializeDateFormatting('zh_CN', null);

  // 请求通知权限 (这个逻辑保留是好的)
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  // [!] 修改这里：调用新的静态初始化方法
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
