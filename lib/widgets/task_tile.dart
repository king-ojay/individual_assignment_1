import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_utils.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskTile({
    Key? key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onToggle != null ? (_) => onToggle!() : null,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  AppDateUtils.formatDate(task.dueDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (task.reminderTime != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.alarm, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    AppDateUtils.formatTime(task.reminderTime!),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
