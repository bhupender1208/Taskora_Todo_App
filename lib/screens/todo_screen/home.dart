part of '../todo_screen.dart';

extension _ToDoScreenHome on _ToDoScreenState {
  Widget _buildHomePage() {
    return SingleChildScrollView(
      key: const ValueKey('home'),
      child: Column(
        children: [
          _buildGreetingCard(),
          const SizedBox(height: 14),
          _buildSummaryCards(),
          const SizedBox(height: 14),
          _buildFilters(),
          const SizedBox(height: 12),
          if (_visibleTasks.isEmpty)
            SizedBox(height: 240, child: _buildEmptyState())
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: _visibleTasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) =>
                  _buildTaskCard(_visibleTasks[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(19, 13, 12, 12),
      height: 82,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.78),
            const Color(0xFFDCE8FF).withValues(alpha: 0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F8FCA).withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_greeting 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You have $_todayCount tasks today',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const _CalendarArt(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.check_rounded,
              value: '$_completedCount',
              label: 'Completed',
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _SummaryCard(
              icon: Icons.format_list_bulleted_rounded,
              value: '$_pendingCount',
              label: 'Pending',
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _SummaryCard(
              icon: Icons.emoji_events_rounded,
              value: '$_progress%',
              label: 'Progress',
              color: const Color(0xFF16BB78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All Tasks', 'Today', 'Important', 'Completed'];
    const icons = {
      'All Tasks': Icons.grid_view_rounded,
      'Today': Icons.calendar_month_rounded,
      'Important': Icons.star_rounded,
      'Completed': Icons.check_circle_rounded,
    };
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = filters[index];
          final selected = _filter == label;
          return Material(
            color: selected ? null : Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => _updateState(() => _filter = label),
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF4F58F7), Color(0xFF7544F7)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.19),
                            blurRadius: 9,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icons[label],
                      size: 17,
                      color: selected ? Colors.white : const Color(0xFF555D7B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF303958),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final accent = task.category == 'Personal'
        ? const Color(0xFF18C985)
        : task.category == 'Work'
        ? AppColors.purple
        : AppColors.purple;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.87),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.94)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5869A7).withValues(alpha: 0.11),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                color: task.completed ? Colors.transparent : accent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 10, 7, 10),
                  child: Row(
                    children: [
                      Tooltip(
                        message: task.completed
                            ? 'Mark incomplete'
                            : 'Mark complete',
                        child: InkWell(
                          onTap: () => _toggleTask(task),
                          customBorder: const CircleBorder(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.completed
                                  ? AppColors.blue
                                  : Colors.transparent,
                              border: Border.all(
                                color: task.completed
                                    ? AppColors.blue
                                    : const Color(0xFFC7CBE0),
                                width: 2.3,
                              ),
                              boxShadow: task.completed
                                  ? [
                                      BoxShadow(
                                        color: AppColors.blue.withValues(
                                          alpha: 0.22,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: task.completed
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 23,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: task.completed
                                    ? const Color(0xFF8A8EA2)
                                    : AppColors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                  width: 205,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 15,
                                        color: task.completed
                                            ? AppColors.muted
                                            : AppColors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _formatCreatedAt(task.createdAt),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: task.completed
                                                ? AppColors.muted
                                                : AppColors.blue,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (task.category.isNotEmpty)
                                  _CategoryTag(
                                    label: task.category,
                                    isPriority: task.priority,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Task options',
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Color(0xFF747C9E),
                        ),
                        onSelected: (value) => _onTaskMenu(task, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit task'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'important',
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                task.priority ? Icons.star : Icons.star_border,
                              ),
                              title: Text(
                                task.priority
                                    ? 'Remove importance'
                                    : 'Mark important',
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.delete_outline),
                              title: Text('Delete task'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCreatedAt(DateTime createdAt) {
    final localCreatedAt = createdAt.toLocal();
    final month = localCreatedAt.month.toString().padLeft(2, '0');
    final day = localCreatedAt.day.toString().padLeft(2, '0');
    final date = '$month/$day';
    final hour = localCreatedAt.hour % 12 == 0 ? 12 : localCreatedAt.hour % 12;
    final minute = localCreatedAt.minute.toString().padLeft(2, '0');
    final period = localCreatedAt.hour < 12 ? 'AM' : 'PM';
    final time = '$hour:$minute $period';
    return '$date $time';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.76),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: AppColors.purple,
                size: 34,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _filter == 'Completed' ? 'Nothing completed yet' : 'All clear!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _filter == 'Today'
                  ? 'No tasks scheduled for today.'
                  : 'There are no tasks in this list.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
