import 'package:flutter/material.dart';
import 'task.dart';
import 'storage_service.dart';
import 'add_task_dialog.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Task> tasks = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    tasks = await StorageService.loadTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar'), backgroundColor: Colors.blue),
      body: Column(
        children: [
          // Month header
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              'October 2025',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Calendar grid
          Container(
            height: 300,
            padding: EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 days per week
              ),
              itemCount: 31, // October has 31 days
              itemBuilder: (context, index) {
                int dayNumber = index + 1;
                DateTime currentDate = DateTime(2025, 10, dayNumber);
                bool hasTasks = _dateHasTasks(currentDate);

                // Check if this date is selected
                bool isSelected =
                    selectedDate != null &&
                    selectedDate!.day == currentDate.day &&
                    selectedDate!.month == currentDate.month &&
                    selectedDate!.year == currentDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = currentDate;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors
                                .blue // Selected date is darker blue
                          : hasTasks
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Show tasks for selected date
          if (selectedDate != null)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Tasks for ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: tasks
                          .where(
                            (task) =>
                                task.dueDate.day == selectedDate!.day &&
                                task.dueDate.month == selectedDate!.month &&
                                task.dueDate.year == selectedDate!.year,
                          )
                          .map(
                            (task) => Card(
                              margin: EdgeInsets.all(8),
                              child: ListTile(
                                title: Text(task.title),
                                subtitle: Text(
                                  task.description.isNotEmpty
                                      ? task.description
                                      : 'No description',
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTask() async {
    final task = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(),
    );
    if (task != null) {
      tasks.add(task);
      await StorageService.saveTasks(tasks);
      setState(() {});
    }
  }

  bool _dateHasTasks(DateTime date) {
    return tasks.any(
      (task) =>
          task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day,
    );
  }
}
