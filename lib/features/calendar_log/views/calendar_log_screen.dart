// 路径: lib/features/calendar_log/views/calendar_log_screen.dart
// 职责: “日历日志”功能的UI界面与基础逻辑。
// [!] 这是使用flutter_slidable实现“左滑显示删除按钮”功能的最终版本

import 'package:flutter/material.dart';
import 'package:my_gym_app/core/services/local_storage_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // 1. 导入新库
import 'package:vibration/vibration.dart';

class CalendarLogScreen extends StatefulWidget {
  const CalendarLogScreen({super.key});

  @override
  State<CalendarLogScreen> createState() => _CalendarLogScreenState();
}

class _CalendarLogScreenState extends State<CalendarLogScreen> {
  // --- 状态变量 ---
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final LocalStorageService _storageService = LocalStorageService();
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEventsFromStorage();
  }

  // --- 核心逻辑方法 ---

  Future<void> _loadEventsFromStorage() async {
    final loadedEvents = await _storageService.loadEvents();
    setState(() {
      _events = loadedEvents;
    });
  }

  Future<void> _addEvent(String event) async {
    final day = DateTime.utc(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    setState(() {
      if (_events[day] != null) {
        _events[day]!.add(event);
      } else {
        _events[day] = [event];
      }
    });

    // 2. 在事件添加后，立刻给出震动反馈
    // 检查设备是否有自定义震动强度的能力
    if (await Vibration.hasAmplitudeControl() ?? false) {
      // 如果有，使用一个较低的强度来表示轻微的反馈
      Vibration.vibrate(duration: 100, amplitude: 64);
    } else {
      // 如果没有，就使用默认的短促震动
      Vibration.vibrate(duration: 100);
    }

    await _storageService.saveEvents(_events);
  }

  Future<void> _deleteEvent(String event) async {
    final day = DateTime.utc(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    setState(() {
      if (_events[day] != null) {
        _events[day]!.remove(event);
        if (_events[day]!.isEmpty) {
          _events.remove(day);
        }
      }
    });

    await _storageService.saveEvents(_events);
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _showAddLogDialog() {
    if (_selectedDay == null) return;
    final List<String> workoutOptions = ['练胸', '练背', '练腿', '练肩', '手臂', '有氧'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '选择训练部位',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: workoutOptions.map((workout) {
                  return ElevatedButton(
                    onPressed: () {
                      _addEvent(workout);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(workout),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTableCalendar(),
              const SizedBox(height: 8.0),
              _buildEventList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- UI构建方法 ---
  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'zh_CN',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      eventLoader: _getEventsForDay,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue[800],
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }

  // [!] 更新事件列表以支持左滑出现删除按钮
  Widget _buildEventList() {
    if (_selectedDay == null) return const SizedBox.shrink();
    final selectedEvents = _getEventsForDay(_selectedDay!);
    if (selectedEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "今日无训练记录",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        // 2. 使用 Slidable 组件包裹
        return Slidable(
          key: Key('${_selectedDay!.toIso8601String()}_$event$index'),
          // 右侧滑出的操作面板
          endActionPane: ActionPane(
            motion: const StretchMotion(), // 滑出动画
            children: [
              // 删除按钮
              SlidableAction(
                onPressed: (context) {
                  _deleteEvent(event);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('“$event”记录已删除')));
                },
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          // Slidable 的子组件，即我们的日志卡片
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.fitness_center,
                color: Colors.blue,
                size: 30,
              ),
              title: Text(
                event,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text("向左滑动以操作"),
              onTap: () {},
            ),
          ),
        );
      },
    );
  }
}
