class Task {
  Task({
    required this.title,
    required this.due,
    DateTime? createdAt,
    this.category = '',
    this.priority = false,
    this.completed = false,
  }) : createdAt = createdAt ?? DateTime.now();

  String title;
  String due;
  final DateTime createdAt;
  String category;
  bool priority;
  bool completed;

  Map<String, Object> toJson() => {
    'title': title,
    'due': due,
    'createdAt': createdAt.toIso8601String(),
    'category': category,
    'priority': priority,
    'completed': completed,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final due = json['due'];
    final createdAtValue = json['createdAt'];
    final category = json['category'];
    final priority = json['priority'];
    final completed = json['completed'];
    if (title is! String ||
        due is! String ||
        category is! String ||
        priority is! bool ||
        completed is! bool) {
      throw const FormatException('A saved task has invalid fields.');
    }
    if (createdAtValue != null && createdAtValue is! String) {
      throw const FormatException('A saved task has an invalid creation date.');
    }
    final createdAt = createdAtValue == null
        ? DateTime.now()
        : DateTime.tryParse(createdAtValue as String);
    if (createdAt == null) {
      throw const FormatException('A saved task has an invalid creation date.');
    }
    return Task(
      title: title,
      due: due,
      createdAt: createdAt,
      category: category,
      priority: priority,
      completed: completed,
    );
  }
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.due,
    required this.category,
    required this.priority,
  });

  final String title;
  final String due;
  final String category;
  final bool priority;
}
