
import 'dart:async';

import 'package:flutter/material.dart';

typedef WorkoutDurationCallback = void Function(Duration duration);

class WorkoutTimer extends StatefulWidget {
    final WorkoutDurationCallback? onDurationUpdated;
  const WorkoutTimer({super.key, this.onDurationUpdated});

  @override
  State<WorkoutTimer> createState() => WorkoutTimerState();
}

class WorkoutTimerState extends State<WorkoutTimer> {
  late Timer _timer;
  Duration _workoutDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _workoutDuration += const Duration(seconds: 1);
      });
    });
  }

void reset() {
    // 1. Cancel the current timer
    _timer.cancel();
    // 2. Reset the duration
    setState(() {
      _workoutDuration = Duration.zero;
    });
    // 3. Start a new timer
    _startTimer();
  }

  Duration getDuration() {
    return _workoutDuration;
  }
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // Only this widget rebuilds every second
    return Text(
      _formatDuration(_workoutDuration),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    );
  }
}