import 'package:flutter/material.dart';
import 'task.dart';

// Dialog for adding new tasks
class AddTaskDialog extends StatefulWidget {
  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController =
      TextEditingController(); // Controller for title input
  final _descriptionController =
      TextEditingController(); // Controller for description
  DateTime _selectedDate = DateTime.now(); // Default to today's date

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title input field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          // put in a description input field
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          SizedBox(height: 16),
          // Date picker - tappable to change date
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Due Date'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            onTap: _pickDate, // Open date picker when tapped
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Only save if title is not empty
            if (_titleController.text.isNotEmpty) {
              final task = Task(
                title: _titleController.text,
                description: _descriptionController.text,
                dueDate: _selectedDate,
              );
              Navigator.pop(context, task); // Return the created task
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  // Show Flutter's date picker and update selected date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked; // Update selected date
      });
    }
  }
}
