// 路径: lib/app/widgets/main_scaffold.dart
// 职责: App的主框架，包含底部导航栏和页面切换逻辑。

import 'package:flutter/material.dart';
import 'package:my_gym_app/features/calendar_log/views/calendar_log_screen.dart';
import 'package:my_gym_app/features/timer/views/timer_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // 当前选中的页面索引
  int _selectedIndex = 0;

  // 页面列表
  static const List<Widget> _widgetOptions = <Widget>[
    TimerScreen(),
    CalendarLogScreen(),
  ];

  // 点击底部导航项时调用的方法
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 主体内容根据选中的索引显示不同的页面
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: '计时器',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '日志',
          ),
        ],
        currentIndex: _selectedIndex,
        // 选中项的颜色
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

// ======================================================================
