import 'dart:convert';

// Task model ,defines the structure of a task
// Contains all properties needed for a study task
class Task {
  final String title; //  Name of the task
  final String description;
  final DateTime dueDate; //  When the task is due
  final DateTime? reminderTime;
  final bool isCompleted; // Track if task is done

  Task({
    required this.title,
    this.description = '',
    required this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
  });

  // Convert Task object to JSON format for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch, // Store as timestamp
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  // Create Task object from JSON when loading from storage
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
      reminderTime: json['reminderTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['reminderTime'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
