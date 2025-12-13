import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Priority { low, medium, high, critical }
enum Category { work, study, personal, health, other }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  Priority priority;
  Category category;
  bool isCompleted;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = Priority.medium,
    this.category = Category.personal,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.index,
      'category': category.index,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      priority: Priority.values[map['priority']],
      category: Category.values[map['category']],
      isCompleted: map['isCompleted'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Get priority color
  Color get priorityColor {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.blue;
      case Priority.high:
        return Colors.orange;
      case Priority.critical:
        return Colors.red;
    }
  }

  // Get priority text
  String get priorityText {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.critical:
        return 'Critical';
    }
  }

  // Get formatted due date
  String get formattedDueDate {
    return DateFormat('MMM dd, yyyy').format(dueDate);
  }

  // Get category icon
  IconData get categoryIcon {
    switch (category) {
      case Category.work:
        return Icons.work;
      case Category.study:
        return Icons.school;
      case Category.personal:
        return Icons.person;
      case Category.health:
        return Icons.favorite;
      case Category.other:
        return Icons.category;
    }
  }

  // Get category text
  String get categoryText {
    switch (category) {
      case Category.work:
        return 'Work';
      case Category.study:
        return 'Study';
      case Category.personal:
        return 'Personal';
      case Category.health:
        return 'Health';
      case Category.other:
        return 'Other';
    }
  }

  // Copy with updates
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    Category? category,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}