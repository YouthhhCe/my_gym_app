// 路径: lib/features/timer/views/timer_screen.dart
// 职责: “计时器”功能的UI界面与核心逻辑。
// [!] 这是添加了自定义时间选择器功能的最终版本

import 'dart:async';
import 'package:flutter/cupertino.dart'; // 导入Cupertino库以使用iOS风格的组件
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // --- 生命周期方法 ---
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- 核心逻辑方法 ---

  void _startPauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      if (_currentSeconds == 0) {
        _currentSeconds = _totalSeconds;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentSeconds > 0) {
            _currentSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            // TODO: 在这里添加声音和震动提醒
          }
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _currentSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _setPresetTime(int seconds) {
    _timer?.cancel();
    setState(() {
      _totalSeconds = seconds;
      _currentSeconds = seconds;
      _isRunning = false;
    });
  }

  // [新增] 显示自定义时间选择器的模态窗口
  void _showCustomTimePicker() {
    // 临时存储用户在选择器上滚动到的时间
    Duration selectedDuration = Duration(seconds: _totalSeconds);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // iOS风格的时间选择器
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms, // 显示分钟和秒
                  initialTimerDuration: selectedDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    // 当用户滚动时，更新临时存储的时间
                    selectedDuration = newDuration;
                  },
                ),
              ),
              // “确定”按钮
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
                    // 只有当选择的时间大于0时才设置
                    if (selectedDuration.inSeconds > 0) {
                      _setPresetTime(selectedDuration.inSeconds);
                    }
                    // 关闭底部弹窗
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

  // --- 辅助方法 ---
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

  // --- 构建UI组件的辅助方法 ---
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
      onPressed: _showCustomTimePicker, // [!] 调用新创建的方法
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
