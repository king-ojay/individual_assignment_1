import 'package:flutter/material.dart';
import 'task.dart';
import 'storage_service.dart';
import 'date_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Study Planner Test', home: TestScreen());
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await StorageService.loadTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  Future<void> _addTestTask() async {
    final newTask = Task(
      title: 'Test Task ${tasks.length + 1}',
      description: 'This is a test',
      dueDate: DateTime.now(),
    );

    tasks.add(newTask);
    await StorageService.saveTasks(tasks);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Storage Test'), backgroundColor: Colors.blue),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks. Tap + to test storage!'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(DateHelper.formatDate(task.dueDate)),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestTask,
        child: Icon(Icons.add),
      ),
    );
  }
}
