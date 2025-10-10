import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

// Storage service handles saving and loading tasks locally
// Uses SharedPreferences to store tasks as JSON strings
class StorageService {
  static const String _key = 'tasks'; // Key that is used to store tasks

  // Save list of tasks to local storage
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert each task to JSON string
    final jsonList = tasks.map((task) => jsonEncode(task.toJson())).toList();
    // Save as list of strings
    await prefs.setStringList(_key, jsonList);
  }

  // Load tasks from the local storage
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    // Get saved JSON strings, or empty list if none exist
    final jsonList = prefs.getStringList(_key) ?? [];
    // Convert each JSON string back to Task object
    return jsonList.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  // Return storage method name for the settings display
  static String getStorageType() => 'SharedPreferences';
}
