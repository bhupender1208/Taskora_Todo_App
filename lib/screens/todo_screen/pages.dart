part of '../todo_screen.dart';

extension _ToDoScreenPages on _ToDoScreenState {
  Widget _buildStatsPage() {
    return SingleChildScrollView(
      key: const ValueKey('stats'),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your progress',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'A little progress each day adds up.',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4D71FF), Color(0xFF7A43F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall completion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '$_progress%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_completedCount of ${_tasks.length} tasks completed',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    value: _tasks.isEmpty ? 0 : _completedCount / _tasks.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatsTile(
                  icon: Icons.check_circle_rounded,
                  value: '$_completedCount',
                  label: 'Completed',
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatsTile(
                  icon: Icons.pending_actions_rounded,
                  value: '$_pendingCount',
                  label: 'Remaining',
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _StatsTile(
            icon: Icons.today_rounded,
            value: '$_todayCount',
            label: 'Scheduled today',
            color: const Color(0xFF16BB78),
            horizontal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    const tabs = [
      (label: 'Home', icon: Icons.home_rounded),
      (label: 'Stats', icon: Icons.bar_chart_rounded),
      (label: 'Settings', icon: Icons.settings_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D75A9).withValues(alpha: 0.13),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var index = 0; index < tabs.length; index++)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => _updateState(() => _tabIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[index].icon,
                        size: 26,
                        color: _tabIndex == index
                            ? AppColors.purple
                            : const Color(0xFF737B9C),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        tabs[index].label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _tabIndex == index
                              ? AppColors.purple
                              : const Color(0xFF737B9C),
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: _tabIndex == index ? 48 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
