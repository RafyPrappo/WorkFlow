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

  // Load tasks from shared preferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksData = prefs.getStringList('tasks') ?? [];

    _tasks = tasksData.map((taskString) {
      try {
        // Simple parsing - in real app use proper JSON
        final now = DateTime.now();
        return Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Sample Task ${_tasks.length + 1}',
          description: 'This is a sample task',
          dueDate: now.add(Duration(days: _tasks.length + 1)),
          priority: Priority.values[_tasks.length % 4],
          category: Category.values[_tasks.length % 5],
          isCompleted: _tasks.length % 3 == 0,
        );
      } catch (e) {
        return Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Error Task',
          description: 'Could not load task',
          dueDate: DateTime.now(),
        );
      }
    }).toList();

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

  // Add sample tasks for testing
  Future<void> addSampleTasks() async {
    final now = DateTime.now();

    final sampleTasks = [
      Task(
        id: '1',
        title: 'Complete Flutter project setup',
        description: 'Set up GitHub and basic project structure',
        dueDate: now,
        priority: Priority.high,
        category: Category.study,
        isCompleted: true,
      ),
      Task(
        id: '2',
        title: 'Design login screen UI',
        description: 'Create responsive login interface',
        dueDate: now.add(const Duration(days: 1)),
        priority: Priority.medium,
        category: Category.work,
      ),
      Task(
        id: '3',
        title: 'Implement task model',
        description: 'Create Task class with priority and categories',
        dueDate: now.add(const Duration(days: 2)),
        priority: Priority.critical,
        category: Category.study,
      ),
      Task(
        id: '4',
        title: 'Go for a walk',
        description: '30 minutes of exercise',
        dueDate: now.add(const Duration(days: 1)),
        priority: Priority.low,
        category: Category.health,
      ),
      Task(
        id: '5',
        title: 'Weekly grocery shopping',
        description: 'Buy fruits, vegetables, and essentials',
        dueDate: now.add(const Duration(days: 3)),
        priority: Priority.medium,
        category: Category.personal,
      ),
    ];

    _tasks.addAll(sampleTasks);
    await _saveTasks();
    notifyListeners();
  }
}