import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_dialog.dart';
import '../utils/date_utils.dart';

class TodayScreen extends StatefulWidget {
  final StorageService storageService;

  const TodayScreen({Key? key, required this.storageService}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<Task> todayTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    setState(() => isLoading = true);

    try {
      final allTasks = await widget.storageService.getTasks();
      final today = DateTime.now();

      setState(() {
        todayTasks = allTasks
            .where((task) => AppDateUtils.isSameDay(task.dueDate, today))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Error loading tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Tasks'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todayTasks.isEmpty
          ? _buildEmptyState()
          : _buildTaskList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks for today',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final completedTasks = todayTasks
        .where((task) => task.isCompleted)
        .toList();
    final incompleteTasks = todayTasks
        .where((task) => !task.isCompleted)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadTodayTasks,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          if (incompleteTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pending Tasks (${incompleteTasks.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...incompleteTasks.map(
              (task) => TaskTile(
                task: task,
                onToggle: () => _toggleTaskComplete(task),
                onDelete: () => _deleteTask(task),
                onTap: () => _editTask(task),
              ),
            ),
          ],
          if (completedTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Completed Tasks (${completedTasks.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
            ...completedTasks.map(
              (task) => TaskTile(
                task: task,
                onToggle: () => _toggleTaskComplete(task),
                onDelete: () => _deleteTask(task),
                onTap: () => _editTask(task),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addTask() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );

    if (result != null) {
      try {
        await widget.storageService.saveTask(result);
        await _loadTodayTasks();
        _showSuccessSnackBar('Task added successfully');
      } catch (e) {
        _showErrorSnackBar('Error adding task');
      }
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(taskToEdit: task),
    );

    if (result != null) {
      try {
        await widget.storageService.updateTask(result);
        await _loadTodayTasks();
        _showSuccessSnackBar('Task updated successfully');
      } catch (e) {
        _showErrorSnackBar('Error updating task');
      }
    }
  }

  Future<void> _toggleTaskComplete(Task task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await widget.storageService.updateTask(updatedTask);
      await _loadTodayTasks();
    } catch (e) {
      _showErrorSnackBar('Error updating task');
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.storageService.deleteTask(task.id!);
        await _loadTodayTasks();
        _showSuccessSnackBar('Task deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting task');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
