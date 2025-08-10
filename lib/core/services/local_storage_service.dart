// 路径: lib/core/services/local_storage_service.dart
// 职责: 封装所有与本地存储相关的操作，提供统一的数据读写接口。

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _eventsKey = 'workout_events';

  // 保存训练日志数据
  Future<void> saveEvents(Map<DateTime, List<String>> events) async {
    final prefs = await SharedPreferences.getInstance();

    // SharedPreferences不能直接存储DateTime对象，需要先转换成字符串
    // 我们将Map<DateTime, List>转换为Map<String, List>
    final Map<String, List<String>> stringKeyEvents = events.map((key, value) {
      // 使用ISO 8601格式的字符串来表示日期，确保唯一性和可解析性
      return MapEntry(key.toIso8601String(), value);
    });

    // 将整个map编码成一个JSON字符串进行存储
    final String encodedEvents = json.encode(stringKeyEvents);
    await prefs.setString(_eventsKey, encodedEvents);
  }

  // 加载训练日志数据
  Future<Map<DateTime, List<String>>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedEvents = prefs.getString(_eventsKey);

    if (encodedEvents == null) {
      return {}; // 如果没有数据，返回一个空map
    }

    // 解码JSON字符串
    final Map<String, dynamic> decodedMap = json.decode(encodedEvents);

    // 将解码后的Map<String, dynamic>转换回我们需要的Map<DateTime, List<String>>
    final Map<DateTime, List<String>> events = decodedMap.map((key, value) {
      // 将字符串key解析回DateTime对象
      final dateTimeKey = DateTime.parse(key);
      // 将值转换为List<String>
      final stringListValue = List<String>.from(value);
      return MapEntry(dateTimeKey, stringListValue);
    });

    return events;
  }
}
