// 路径: lib/main.dart
// 职责: App的唯一入口，配置主题和首页。
// [!] 这是修复了中文语言环境问题的版本

import 'package:flutter/material.dart';
import 'package:my_gym_app/app/widgets/main_scaffold.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. 导入intl库

void main() async {
  // 2. 将main函数变为异步
  // 3. 确保Flutter的Widgets绑定已经初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 4. 初始化中文的日期格式化数据
  await initializeDateFormatting('zh_CN', null);

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
