import 'package:flutter/material.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

class PomodoroSession {
  String id;
  String? taskId; // Which task is being worked on
  DateTime startTime;
  DateTime? endTime;
  Duration duration;
  PomodoroPhase phase;
  bool isCompleted;

  PomodoroSession({
    required this.id,
    this.taskId,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.phase,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration.inSeconds,
      'phase': phase.index,
      'isCompleted': isCompleted,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'],
      taskId: map['taskId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      duration: Duration(seconds: map['duration']),
      phase: PomodoroPhase.values[map['phase']],
      isCompleted: map['isCompleted'],
    );
  }

  // Get phase name
  String get phaseName {
    switch (phase) {
      case PomodoroPhase.focus:
        return 'Focus Time';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  // Get phase color
  Color get phaseColor {
    switch (phase) {
      case PomodoroPhase.focus:
        return Colors.red;
      case PomodoroPhase.shortBreak:
        return Colors.green;
      case PomodoroPhase.longBreak:
        return Colors.blue;
    }
  }

  // Get recommended duration for phase
  static Duration getPhaseDuration(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return const Duration(minutes: 25);
      case PomodoroPhase.shortBreak:
        return const Duration(minutes: 5);
      case PomodoroPhase.longBreak:
        return const Duration(minutes: 15);
    }
  }
}