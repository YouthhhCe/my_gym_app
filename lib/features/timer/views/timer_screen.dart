// 路径: lib/features/timer/views/timer_screen.dart
// 职责: “计时器”功能的UI界面与核心逻辑。

import 'dart:async';
import 'package:flutter/cupertino.dart'; // 导入Cupertino库以使用iOS风格的组件
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_gym_app/core/services/notification_service.dart'; //自定义服务类

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // --- 状态变量 ---
  Timer? _timer;
  int _totalSeconds = 90;
  int _currentSeconds = 90;
  bool _isRunning = false;
  // [!] 不再需要 final service = FlutterBackgroundService();

  // --- 生命周期方法 ---
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- 核心逻辑方法 ---

  void _startPauseTimer() async {
    if (_isRunning) {
      // 如果正在运行，则暂停
      _timer?.cancel();
      // [!] 修改这里：调用新的静态方法停止服务
      NotificationService.stopService();
      setState(() {
        _isRunning = false;
      });
    } else {
      // 如果未运行，则开始
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        if (_currentSeconds == 0) {
          _currentSeconds = _totalSeconds;
        }

        // [!] 修改这里：调用新的静态方法启动计时器
        NotificationService.startTimer(duration: _currentSeconds);

        // UI上的计时器也同步启动
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            if (_currentSeconds > 0) {
              _currentSeconds--;
            } else {
              timer.cancel();
              _isRunning = false;
            }
          });
        });
        setState(() {
          _isRunning = true;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('需要通知权限才能在后台提醒您！')));
      }
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    // [!] 修改这里：调用新的静态方法停止服务
    NotificationService.stopService();
    setState(() {
      _currentSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  // _setPresetTime, _showCustomTimePicker, _formatDuration 和 build 方法都不需要修改
  // ... (下面的所有代码都保持不变)

  void _setPresetTime(int seconds) {
    if (_isRunning) {
      _resetTimer();
    }
    if (mounted) {
      setState(() {
        _totalSeconds = seconds;
        _currentSeconds = seconds;
      });
    }
  }

  void _showCustomTimePicker() {
    Duration selectedDuration = Duration(seconds: _totalSeconds);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms,
                  initialTimerDuration: selectedDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    selectedDuration = newDuration;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (selectedDuration.inSeconds > 0) {
                      _setPresetTime(selectedDuration.inSeconds);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('确定', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDuration(_currentSeconds),
                      style: GoogleFonts.robotoMono(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '组间休息',
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildPresetButton('60s', 60),
                  _buildPresetButton('90s', 90),
                  _buildPresetButton('120s', 120),
                  _buildAddButton(),
                ],
              ),
              const SizedBox(height: 24),
              _buildMainActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String text, int seconds) {
    final bool isSelected = _totalSeconds == seconds && !_isRunning;
    return ElevatedButton(
      onPressed: () => _setPresetTime(seconds),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Colors.blue.withOpacity(0.2)
            : Colors.grey[200],
        foregroundColor: isSelected ? Colors.blue[800] : Colors.grey[800],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide(color: Colors.blue[800]!, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _showCustomTimePicker,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Icon(Icons.add, size: 28),
    );
  }

  Widget _buildMainActionButton() {
    if (_isRunning ||
        (_currentSeconds > 0 && _currentSeconds < _totalSeconds)) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _startPauseTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '暂停',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _resetTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '重置',
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _startPauseTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            '开始',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }
  }
}
