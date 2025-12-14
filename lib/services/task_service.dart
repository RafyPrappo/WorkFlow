import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get incompleteTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  List<Task> get highPriorityTasks =>
      _tasks.where((task) =>
      task.priority == Priority.high || task.priority == Priority.critical)
          .toList();

  TaskService() {
    _loadTasks();
  }

  // Load tasks from shared preferences - FIXED
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksData = prefs.getStringList('tasks') ?? [];

    _tasks = tasksData.map((taskString) {
      try {
        // Parse the task string back to a Task object
        // This is a simple parsing - you should use proper JSON parsing
        // The taskString is the result of task.toMap().toString()

        // Remove the curly braces and split into key-value pairs
        final cleanedString = taskString.replaceAll('{', '').replaceAll('}', '');
        final pairs = cleanedString.split(', ');

        // Create a map from the string
        Map<String, dynamic> map = {};
        for (final pair in pairs) {
          final keyValue = pair.split(': ');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim();
            final value = keyValue[1].trim();

            // Parse values based on key
            if (key == 'id') {
              map[key] = value;
            } else if (key == 'title') {
              map[key] = value;
            } else if (key == 'description') {
              map[key] = value;
            } else if (key == 'dueDate') {
              map[key] = value;
            } else if (key == 'priority') {
              map[key] = int.parse(value);
            } else if (key == 'category') {
              map[key] = int.parse(value);
            } else if (key == 'isCompleted') {
              map[key] = value.toLowerCase() == 'true';
            } else if (key == 'createdAt') {
              map[key] = value;
            }
          }
        }

        // Create Task from map
        return Task(
          id: map['id'],
          title: map['title'],
          description: map['description'] ?? '',
          dueDate: DateTime.parse(map['dueDate']),
          priority: Priority.values[map['priority']],
          category: Category.values[map['category']],
          isCompleted: map['isCompleted'] ?? false,
          createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
        );
      } catch (e) {
        print('Error loading task: $e');
        return null;
      }
    }).where((task) => task != null).cast<Task>().toList();

    notifyListeners();
  }

  // Save tasks to shared preferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksData = _tasks.map((task) => task.toMap().toString()).toList();
    await prefs.setStringList('tasks', tasksData);
  }

  // Add new task
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  // Update existing task
  Future<void> updateTask(String taskId, Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasks();
      notifyListeners();
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await _saveTasks();
      notifyListeners();
    }
  }

  // Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Get tasks for a specific day
  List<Task> getTasksForDay(DateTime date) {
    return _tasks.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
  }

  // Clear all tasks (for testing)
  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _saveTasks();
    notifyListeners();
  }

  // Add sample tasks for testing - KEEP BUT UPDATE
  Future<void> addSampleTasks() async {
    final now = DateTime.now();

    final sampleTasks = [
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Complete Flutter project setup',
        description: 'Set up GitHub and basic project structure',
        dueDate: now,
        priority: Priority.high,
        category: Category.study,
        isCompleted: true,
      ),
      Task(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Design login screen UI',
        description: 'Create responsive login interface',
        dueDate: now.add(const Duration(days: 1)),
        priority: Priority.medium,
        category: Category.work,
      ),
      Task(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'Implement task model',
        description: 'Create Task class with priority and categories',
        dueDate: now.add(const Duration(days: 2)),
        priority: Priority.critical,
        category: Category.study,
      ),
    ];

    _tasks.addAll(sampleTasks);
    await _saveTasks();
    notifyListeners();
  }

  // Get highest priority for a specific day
  Priority? getHighestPriorityForDay(DateTime date) {
    final tasksForDay = getTasksForDay(date);
    final incompleteTasks = tasksForDay.where((task) => !task.isCompleted).toList();

    if (incompleteTasks.isEmpty) return null;

    // Find the highest priority
    Priority highestPriority = incompleteTasks.first.priority;

    for (final task in incompleteTasks) {
      if (_getPriorityValue(task.priority) > _getPriorityValue(highestPriority)) {
        highestPriority = task.priority;
      }
    }

    return highestPriority;
  }

  // Helper to get priority numeric value
  int _getPriorityValue(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
      case Priority.critical:
        return 4;
    }
  }
}