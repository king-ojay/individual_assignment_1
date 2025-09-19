import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_utils.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskDialog({Key? key, this.taskToEdit}) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedReminderTime;
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedDate = task.dueDate;
      _selectedReminderTime = task.reminderTime;
      _hasReminder = task.reminderTime != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.taskToEdit == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field (Required)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field (Optional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Due date selector (Required)
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Due Date *'),
                subtitle: Text(AppDateUtils.formatDate(_selectedDate)),
                onTap: _selectDate,
              ),

              // Reminder toggle
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() {
                    _hasReminder = value;
                    if (!value) {
                      _selectedReminderTime = null;
                    }
                  });
                },
              ),

              // Reminder time selector (Optional)
              if (_hasReminder)
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Reminder Time'),
                  subtitle: Text(
                    _selectedReminderTime != null
                        ? AppDateUtils.formatTime(_selectedReminderTime!)
                        : 'Select time',
                  ),
                  onTap: _selectReminderTime,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text(widget.taskToEdit == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedReminderTime ?? DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedReminderTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.taskToEdit?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDate,
        reminderTime: _hasReminder ? _selectedReminderTime : null,
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
      );

      Navigator.of(context).pop(task);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
