part of '../todo_screen.dart';

extension _ToDoScreenActions on _ToDoScreenState {
  Future<void> _addTask() async {
    final draft = await _showTaskEditor();
    if (draft == null || !mounted) return;
    _updateState(() {
      _tasks.insert(
        0,
        Task(
          title: draft.title,
          due: draft.due,
          category: draft.category,
          priority: draft.priority,
        ),
      );
      _filter = 'All Tasks';
      _tabIndex = 0;
    });
    await _persistAndReport();
  }

  Future<void> _editTask(Task task) async {
    final draft = await _showTaskEditor(task: task);
    if (draft == null || !mounted) return;
    _updateState(() {
      task
        ..title = draft.title
        ..due = draft.due
        ..category = draft.category
        ..priority = draft.priority;
    });
    await _persistAndReport();
  }

  Future<TaskDraft?> _showTaskEditor({Task? task}) async {
    return showDialog<TaskDraft>(
      context: context,
      builder: (_) => _TaskEditorDialog(task: task),
    );
  }

  Future<void> _toggleTask(Task task) async {
    _updateState(() => task.completed = !task.completed);
    await _persistAndReport();
  }

  Future<void> _onTaskMenu(Task task, String action) async {
    switch (action) {
      case 'edit':
        await _editTask(task);
      case 'important':
        _updateState(() => task.priority = !task.priority);
        await _persistAndReport();
      case 'delete':
        final index = _tasks.indexOf(task);
        _updateState(() => _tasks.remove(task));
        await _persistAndReport();
        if (!mounted) return;
        _deleteUndoTimer?.cancel();
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        _deleteSnackBarController = messenger.showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                _deleteUndoTimer?.cancel();
                _deleteUndoTimer = null;
                _updateState(() {
                  _tasks.insert(index.clamp(0, _tasks.length), task);
                });
                unawaited(_persistAndReport());
              },
            ),
          ),
        );
        _deleteUndoTimer = Timer(const Duration(seconds: 6), () {
          _deleteSnackBarController?.close();
          _deleteSnackBarController = null;
          _deleteUndoTimer = null;
        });
    }
  }

  Future<void> _confirmClearCompleted() async {
    if (_completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no completed tasks to clear.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear completed tasks?'),
        content: Text('This will remove $_completedCount completed tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (shouldClear != true || !mounted) return;
    _updateState(() {
      _tasks.removeWhere((task) => task.completed);
      if (_filter == 'Completed') _filter = 'All Tasks';
    });
    await _persistAndReport();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completed tasks cleared.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
