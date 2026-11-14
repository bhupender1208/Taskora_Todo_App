part of '../todo_screen.dart';

extension _ToDoScreenNotifications on _ToDoScreenState {
  Future<void> _showNotificationCenter() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) {
          final openTasks = _tasks.where((task) => !task.completed).toList();
          return AlertDialog(
            backgroundColor: const Color(0xFFF9FAFF),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Reminders',
                    style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Reminder settings',
                  onPressed: () {
                    final enabled = !_notificationsEnabled;
                    _updateState(() => _notificationsEnabled = enabled);
                    updateDialog(() => _notificationsEnabled = enabled);
                    unawaited(_persistAndReport());
                  },
                  icon: Icon(
                    _notificationsEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    color: _notificationsEnabled ? AppColors.purple : AppColors.muted,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _notificationsEnabled
                        ? 'Your unfinished tasks are listed here.'
                        : 'Reminders are paused. Turn them on to see task reminders here.',
                    style: const TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (!_notificationsEnabled)
                    Center(
                      child: FilledButton.icon(
                        onPressed: () {
                          _updateState(() => _notificationsEnabled = true);
                          updateDialog(() => _notificationsEnabled = true);
                          unawaited(_persistAndReport());
                        },
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('Turn on reminders'),
                      ),
                    )
                  else if (openTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 22),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_alt_rounded,
                              color: Color(0xFF16BB78),
                              size: 38,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'You’re all caught up!',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: openTasks.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final task = openTasks[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.purple,
                            ),
                            title: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(task.due),
                            trailing: TextButton(
                              onPressed: () {
                                _updateState(() => task.completed = true);
                                updateDialog(() {});
                                unawaited(_persistAndReport());
                              },
                              child: const Text('Done'),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _notificationsEnabled
                            ? Icons.info_outline_rounded
                            : Icons.pause_circle_outline_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'In-app reminders are shown while TaskFlow is open.',
                          style: TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Go to tasks'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
    if (!mounted || openSettings != true) return;
    _updateState(() {
      _tabIndex = 0;
      _filter = 'All Tasks';
    });
    await _persistAndReport();
  }
}
