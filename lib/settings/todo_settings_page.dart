part of '../screens/todo_screen.dart';

extension _ToDoSettingsPage on _ToDoScreenState {
  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Make TaskFlow work for you.',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: _settingsCardDecoration,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (value) async {
                  _updateState(() => _notificationsEnabled = value);
                  await _persistAndReport();
                },
                activeTrackColor: AppColors.purple,
                secondary: const _SettingsIcon(
                  icon: Icons.notifications_active_outlined,
                  color: AppColors.purple,
                ),
                title: const Text(
                  'Notifications',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text('Show in-app task reminders'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: _settingsCardDecoration,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: _confirmClearCompleted,
                leading: const _SettingsIcon(
                  icon: Icons.cleaning_services_outlined,
                  color: Color(0xFFFF687A),
                ),
                title: const Text(
                  'Clear completed tasks',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text('$_completedCount completed'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: _settingsCardDecoration,
            child: const Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(18)),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: _SettingsIcon(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.blue,
                ),
                title: Text(
                  'About TaskFlow',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text('Plan · Organize · Achieve'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration get _settingsCardDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.88),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white),
  );
}
