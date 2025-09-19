import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_dialog.dart';
import '../utils/date_utils.dart';

class CalendarScreen extends StatefulWidget {
  final StorageService storageService;

  const CalendarScreen({Key? key, required this.storageService})
    : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  List<Task> allTasks = [];
  List<Task> selectedDayTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await widget.storageService.getTasks();
      setState(() {
        allTasks = tasks;
        _updateSelectedDayTasks();
      });
    } catch (e) {
      _showErrorSnackBar('Error loading tasks');
    }
  }

  void _updateSelectedDayTasks() {
    selectedDayTasks = allTasks
        .where((task) => AppDateUtils.isSameDay(task.dueDate, _selectedDate))
        .toList();
  }

  List<Task> _getTasksForDay(DateTime day) {
    return allTasks
        .where((task) => AppDateUtils.isSameDay(task.dueDate, day))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskForSelectedDay,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map(
                (day) => Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar days
        ...List.generate((daysInMonth + startingWeekday + 6) ~/ 7, (week) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (day) {
              final dayNumber = week * 7 + day - startingWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(width: 40, height: 40);
              }

              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                dayNumber,
              );
              final tasksForDay = _getTasksForDay(date);
              final isSelected = AppDateUtils.isSameDay(date, _selectedDate);
              final isToday = AppDateUtils.isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _updateSelectedDayTasks();
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : isToday
                        ? Colors.blue.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? Colors.blue
                                : Colors.black,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (tasksForDay.isNotEmpty)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  tasksForDay.any((task) => !task.isCompleted)
                                  ? Colors.red
                                  : Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildTaskList() {
    if (selectedDayTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks for ${AppDateUtils.formatDate(_selectedDate)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tasks for ${AppDateUtils.formatDate(_selectedDate)} (${selectedDayTasks.length})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: selectedDayTasks.length,
            itemBuilder: (context, index) {
              final task = selectedDayTasks[index];
              return TaskTile(
                task: task,
                onToggle: () => _toggleTaskComplete(task),
                onDelete: () => _deleteTask(task),
                onTap: () => _editTask(task),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addTaskForSelectedDay() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );

    if (result != null) {
      try {
        await widget.storageService.saveTask(result);
        await _loadTasks();
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
        await _loadTasks();
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
      await _loadTasks();
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
        await _loadTasks();
        _showSuccessSnackBar('Task deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting task');
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
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
