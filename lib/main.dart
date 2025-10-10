import 'package:flutter/material.dart';
import 'today_screen.dart';
import 'calender_screen.dart';
import 'settings_screen.dart';
import 'storage_service.dart';

void main() {
  runApp(StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Study Planner', home: MainScreen());
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TodayScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkReminders();
  }

  Future<void> _checkReminders() async {
    // Wait a moment for the app to fully load
    await Future.delayed(Duration(milliseconds: 500));

    final tasks = await StorageService.loadTasks();
    final now = DateTime.now();

    // Find tasks with reminders for today
    final tasksWithReminders = tasks.where((task) {
      if (task.reminderTime == null || task.isCompleted) return false;

      // Check if reminder is today
      return task.reminderTime!.year == now.year &&
          task.reminderTime!.month == now.month &&
          task.reminderTime!.day == now.day;
    }).toList();

    if (tasksWithReminders.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.alarm, color: Colors.orange),
              SizedBox(width: 8),
              Text('Task Reminders'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have ${tasksWithReminders.length} task(s) with reminders today:',
              ),
              SizedBox(height: 8),
              ...tasksWithReminders.map(
                (task) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${task.title}'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
