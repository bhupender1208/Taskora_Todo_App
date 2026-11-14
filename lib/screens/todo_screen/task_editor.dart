part of '../todo_screen.dart';

class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog({required this.task});

  final Task? task;

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _dueController;
  late final String _dateLabel;
  TimeOfDay? _selectedTime;
  bool _timeWasSelected = false;
  late String _category;
  late bool _priority;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _dateLabel = task?.due.split(',').first ?? 'Today';
    _selectedTime =
        _parseTime(task?.due) ?? (task == null ? TimeOfDay.now() : null);
    _timeWasSelected = task != null && _selectedTime != null;
    _dueController = TextEditingController(
      text: task?.due ?? '$_dateLabel, ${_formatTime(_selectedTime!)}',
    );
    _category = task?.category == 'Personal' || task?.category == 'Work'
        ? task!.category
        : 'Personal';
    _priority = task?.priority ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String? due) {
    if (due == null) return null;
    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(due);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isAfternoon = match.group(3)!.toUpperCase() == 'PM';
    if (hour < 1 || hour > 12 || minute > 59) return null;
    return TimeOfDay(
      hour: (hour % 12) + (isAfternoon ? 12 : 0),
      minute: minute,
    );
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedTime = selected;
      _timeWasSelected = true;
      _dueController.text = '$_dateLabel, ${selected.format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return AlertDialog(
      backgroundColor: const Color(0xFFF9FAFF),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        task == null ? 'New task' : 'Edit task',
        style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: _taskInputDecoration(
                  'Task name',
                  Icons.edit_outlined,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a task name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dueController,
                readOnly: true,
                onTap: _selectTime,
                decoration: _taskInputDecoration(
                  'Due date and time',
                  Icons.schedule,
                  suffixIcon: IconButton(
                    tooltip: 'Choose time',
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in ['Personal', 'Work'])
                    ChoiceChip(
                      label: Text(option),
                      selected: _category == option,
                      onSelected: (_) => setState(() => _category = option),
                      selectedColor: const Color(0xFFE7DFFF),
                      labelStyle: TextStyle(
                        color: _category == option ? AppColors.purple : AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: _category == option
                            ? AppColors.purple.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      showCheckmark: false,
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _priority,
                onChanged: (value) => setState(() => _priority = value),
                activeTrackColor: AppColors.purple,
                title: const Text(
                  'Mark as important',
                  style: TextStyle(fontSize: 14, color: AppColors.ink),
                ),
                secondary: const Icon(Icons.star_rounded, color: AppColors.purple),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              TaskDraft(
                title: _titleController.text.trim(),
                due: _dueAtSubmission(context),
                category: _priority ? 'High' : _category,
                priority: _priority,
              ),
            );
          },
          child: Text(task == null ? 'Add task' : 'Save changes'),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _dueAtSubmission(BuildContext context) {
    final time = !_timeWasSelected && widget.task == null
        ? TimeOfDay.now()
        : _selectedTime;
    if (time == null) return widget.task?.due ?? _dueController.text.trim();
    final date = widget.task == null ? 'Today' : _dateLabel;
    return '$date, ${time.format(context)}';
  }
}

InputDecoration _taskInputDecoration(
  String label,
  IconData icon, {
  Widget? suffixIcon,
}) => InputDecoration(
  labelText: label,
  prefixIcon: Icon(icon, size: 19),
  suffixIcon: suffixIcon,
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFE6E8F2)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.purple),
  ),
);
