class Task {
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime? reminderTime;
  final bool isCompleted;

  Task({
    required this.title,
    this.description = '',
    required this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
      reminderTime: json['reminderTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['reminderTime'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
