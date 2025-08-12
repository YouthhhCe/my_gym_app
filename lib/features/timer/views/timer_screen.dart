// 路径: lib/features/timer/views/timer_screen.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gym_app/core/services/notification_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  Timer? _uiTimer;
  int _totalSeconds = 90;
  int _currentSeconds = 90;
  bool _isRunning = false;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_isRunning && _endTime != null) {
        final remaining = _endTime!.difference(DateTime.now()).inSeconds;
        setState(() {
          if (remaining > 0) {
            _currentSeconds = remaining;
          } else {
            // 当我们回来时，计时器已经结束了，重置UI
            _resetUiToDefault();
          }
        });
      }
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      if (_currentSeconds <= 0) {
        _currentSeconds = _totalSeconds;
      }
      _endTime = DateTime.now().add(Duration(seconds: _currentSeconds));
    });

    NotificationService.scheduleTimer(duration: _currentSeconds);

    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      final remaining = _endTime?.difference(DateTime.now()).inSeconds ?? 0;

      if (remaining > 0) {
        setState(() {
          _currentSeconds = remaining;
        });
      } else {
        _resetUiToDefault();
        timer.cancel();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _uiTimer?.cancel();
    NotificationService.cancelTimer();
  }

  void _resetTimer() {
    _uiTimer?.cancel();
    NotificationService.cancelTimer();
    _resetUiToDefault();
  }

  // 辅助函数，用于将UI重置到初始状态
  void _resetUiToDefault() {
    setState(() {
      _isRunning = false;
      _endTime = null;
      _currentSeconds = _totalSeconds;
    });
  }

  void _setPresetTime(int seconds) {
    if (_isRunning) {
      _resetTimer();
    }
    setState(() {
      _totalSeconds = seconds;
      _currentSeconds = seconds;
    });
  }

  void _startPauseTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  // ... build 相关的所有代码都无需修改 ...

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
    bool showPauseAndReset =
        _isRunning || (_currentSeconds > 0 && _currentSeconds < _totalSeconds);

    if (showPauseAndReset) {
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
              child: Text(
                _isRunning ? '暂停' : '继续',
                style: const TextStyle(fontSize: 18, color: Colors.white),
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
