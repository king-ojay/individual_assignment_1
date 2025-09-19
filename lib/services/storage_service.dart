import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';

  // Get storage type for settings screen
  String get storageType => 'SharedPreferences';

  // Load all tasks from storage
  Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];

      return tasksJson.map((taskString) {
        final Map<String, dynamic> taskMap = json.decode(taskString);
        return Task.fromMap(taskMap);
      }).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  // Save a new task
  Future<int> saveTask(Task task) async {
    try {
      final tasks = await getTasks();
      final newTask = task.copyWith(
        id: task.id ?? DateTime.now().millisecondsSinceEpoch,
      );
      tasks.add(newTask);
      await _saveTasks(tasks);
      return newTask.id!;
    } catch (e) {
      print('Error saving task: $e');
      throw Exception('Failed to save task');
    }
  }

  // Update existing task
  Future<void> updateTask(Task task) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        await _saveTasks(tasks);
      }
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task');
    }
  }

  // Delete task
  Future<void> deleteTask(int taskId) async {
    try {
      final tasks = await getTasks();
      tasks.removeWhere((task) => task.id == taskId);
      await _saveTasks(tasks);
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Failed to delete task');
    }
  }

  // Private method to save tasks to SharedPreferences
  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => json.encode(task.toMap())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }
}
