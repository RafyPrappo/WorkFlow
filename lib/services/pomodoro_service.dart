import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pomodoro_session.dart';

class PomodoroService with ChangeNotifier {
  Timer? _timer;
  Duration _timeRemaining = const Duration(minutes: 25);
  PomodoroPhase _currentPhase = PomodoroPhase.focus;
  bool _isRunning = false;
  int _completedSessions = 0;
  String? _currentTaskId;

  Duration get timeRemaining => _timeRemaining;
  PomodoroPhase get currentPhase => _currentPhase;
  bool get isRunning => _isRunning;
  int get completedSessions => _completedSessions;
  String? get currentTaskId => _currentTaskId;

  PomodoroService() {
    _loadState();
  }

  // Load saved state
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _completedSessions = prefs.getInt('completedSessions') ?? 0;
    notifyListeners();
  }

  // Save state
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedSessions', _completedSessions);
  }

  // Start timer
  void startTimer({String? taskId}) {
    if (_isRunning) return;

    _currentTaskId = taskId;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds <= 0) {
        _completeSession();
      } else {
        _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  // Pause timer
  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // Reset timer
  void resetTimer() {
    _timer?.cancel();
    _timeRemaining = PomodoroSession.getPhaseDuration(_currentPhase);
    _isRunning = false;
    notifyListeners();
  }

  // Complete current session
  void _completeSession() {
    _timer?.cancel();
    _isRunning = false;
    _completedSessions++;

    // Auto-advance to next phase
    if (_currentPhase == PomodoroPhase.focus) {
      // After 4 focus sessions, take long break
      if (_completedSessions % 4 == 0) {
        _currentPhase = PomodoroPhase.longBreak;
      } else {
        _currentPhase = PomodoroPhase.shortBreak;
      }
    } else {
      // After break, go back to focus
      _currentPhase = PomodoroPhase.focus;
    }

    _timeRemaining = PomodoroSession.getPhaseDuration(_currentPhase);
    _saveState();

    // Save session to history
    _saveCompletedSession();

    notifyListeners();
  }

  // Save completed session to history
  Future<void> _saveCompletedSession() async {
    final session = PomodoroSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: _currentTaskId,
      startTime: DateTime.now().subtract(PomodoroSession.getPhaseDuration(_currentPhase)),
      endTime: DateTime.now(),
      duration: PomodoroSession.getPhaseDuration(_currentPhase),
      phase: _currentPhase,
      isCompleted: true,
    );

    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('pomodoroSessions') ?? [];
    sessions.add(session.toMap().toString());
    await prefs.setStringList('pomodoroSessions', sessions);
  }

  // Set phase manually
  void setPhase(PomodoroPhase phase) {
    if (_isRunning) return;

    _currentPhase = phase;
    _timeRemaining = PomodoroSession.getPhaseDuration(phase);
    notifyListeners();
  }

  // Set task for current session
  void setTask(String? taskId) {
    _currentTaskId = taskId;
    notifyListeners();
  }

  // Get progress percentage (0.0 to 1.0)
  double get progress {
    final totalDuration = PomodoroSession.getPhaseDuration(_currentPhase);
    return 1.0 - (_timeRemaining.inSeconds / totalDuration.inSeconds);
  }

  // Format time as MM:SS
  String get formattedTime {
    final minutes = _timeRemaining.inMinutes;
    final seconds = _timeRemaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Clean up
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}