import 'package:flutter/material.dart';
import 'task.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Study Planner', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Study Planner'),
        backgroundColor: Colors.blue,
      ),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks yet! Tap + to add one'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: Text('${task.dueDate.day}/${task.dueDate.month}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTask() {
    setState(() {
      tasks.add(
        Task(
          title: 'Study Flutter',
          description: 'Learn about widgets',
          dueDate: DateTime.now(),
        ),
      );
    });
  }
}
