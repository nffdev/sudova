import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GameTimer extends StatefulWidget {
  final bool isRunning;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const GameTimer({
    super.key,
    this.isRunning = true,
    this.onPause,
    this.onResume,
  });

  @override
  State<GameTimer> createState() => GameTimerState();
}

class GameTimerState extends State<GameTimer> {
  int _seconds = 0;
  Timer? _timer;

  int get seconds => _seconds;

  @override
  void initState() {
    super.initState();
    if (widget.isRunning) _startTimer();
  }

  @override
  void didUpdateWidget(GameTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _startTimer();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void reset() {
    _timer?.cancel();
    setState(() => _seconds = 0);
    if (widget.isRunning) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formatted {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 18, color: AppTheme.mediumGray),
        const SizedBox(width: 6),
        Text(
          _formatted,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.mediumGray,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
