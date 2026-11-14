import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_app/models/task.dart';
import 'package:todo_app/theme/app_colors.dart';

part 'todo_screen/header.dart';
part 'todo_screen/notifications.dart';
part 'todo_screen/home.dart';
part 'todo_screen/pages.dart';
part 'todo_screen/actions.dart';
part 'todo_screen/task_editor.dart';
part '../settings/todo_settings_page.dart';
part '../widgets/todo_screen_components.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  static const _storageKey = 'taskflow_data';
  List<Task> _tasks = [];
  SharedPreferences? _preferences;
  Future<void> _saveQueue = Future<void>.value();
  Timer? _deleteUndoTimer;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _deleteSnackBarController;
  bool _isLoading = true;
  String? _loadError;

  String _filter = 'All Tasks';
  int _tabIndex = 0;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _deleteUndoTimer?.cancel();
    super.dispose();
  }

  void _updateState(VoidCallback callback) => setState(callback);

  List<Task> _defaultTasks() => [
    Task(
      title: 'Finish Flutter project',
      due: 'Today, 7:00 PM',
      category: 'High',
      priority: true,
    ),
    Task(
      title: 'Read Dart documentation',
      due: 'Today, 10:00 AM',
      completed: true,
    ),
    Task(title: 'Go for a walk', due: 'Today, 6:00 PM', category: 'Personal'),
    Task(
      title: 'Plan next week schedule',
      due: 'Tomorrow, 9:00 AM',
      category: 'Work',
    ),
  ];

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedData = preferences.getString(_storageKey);
      var tasks = _defaultTasks();
      var notificationsEnabled = true;
      var needsCreationDateMigration = false;

      if (savedData != null) {
        final decoded = jsonDecode(savedData);
        if (decoded is! Map<String, dynamic> ||
            decoded['tasks'] is! List<dynamic> ||
            decoded['notificationsEnabled'] is! bool) {
          throw const FormatException('Saved TaskFlow data is invalid.');
        }
        tasks = (decoded['tasks'] as List<dynamic>).map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('A saved task is invalid.');
          }
          if (item['createdAt'] == null) needsCreationDateMigration = true;
          return Task.fromJson(item);
        }).toList();
        notificationsEnabled = decoded['notificationsEnabled'] as bool;
      }

      if (needsCreationDateMigration) {
        final migrated = await preferences.setString(
          _storageKey,
          jsonEncode({
            'tasks': tasks.map((task) => task.toJson()).toList(),
            'notificationsEnabled': notificationsEnabled,
          }),
        );
        if (!migrated) {
          throw Exception('The device rejected the task date migration.');
        }
      }

      if (!mounted) return;
      setState(() {
        _preferences = preferences;
        _tasks = tasks;
        _notificationsEnabled = notificationsEnabled;
        _isLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _persistData() async {
    final preferences = _preferences;
    if (preferences == null) {
      throw Exception('Task storage is not ready.');
    }
    final snapshot = jsonEncode({
      'tasks': _tasks.map((task) => task.toJson()).toList(),
      'notificationsEnabled': _notificationsEnabled,
    });
    Future<void> writeSnapshot() async {
      final saved = await preferences.setString(_storageKey, snapshot);
      if (!saved) throw Exception('The device rejected the saved changes.');
    }

    final write = _saveQueue.then<void>(
      (_) => writeSnapshot(),
      onError: (Object _) => writeSnapshot(),
    );
    _saveQueue = write.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    await write;
  }

  Future<void> _persistAndReport() async {
    try {
      await _persistData();
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Could not save your changes: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  int get _completedCount => _tasks.where((task) => task.completed).length;
  int get _pendingCount => _tasks.length - _completedCount;
  bool _wasCreatedToday(Task task) {
    final now = DateTime.now();
    final createdAt = task.createdAt.toLocal();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  int get _todayCount => _tasks.where(_wasCreatedToday).length;
  int get _progress =>
      _tasks.isEmpty ? 0 : (_completedCount / _tasks.length * 100).round();

  List<Task> get _visibleTasks {
    final tasks = switch (_filter) {
      'Today' => _tasks.where(_wasCreatedToday).toList(),
      'Important' =>
        _tasks.where((task) => task.priority && !task.completed).toList(),
      'Completed' => _tasks.where((task) => task.completed).toList(),
      _ => List<Task>.of(_tasks),
    };
    return tasks;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/todo.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.06),
                  const Color(0xFFF2F1FF).withValues(alpha: 0.26),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final panelWidth = width < 560 ? width : 560.0;
                final panelHeight = (constraints.maxHeight - 24).clamp(
                  0.0,
                  double.infinity,
                );
                return Center(
                  child: Container(
                    width: panelWidth,
                    height: panelHeight,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(
                        width < 560 ? 24 : 34,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.52),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF5365B9,
                          ).withValues(alpha: 0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            _buildHeader(),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: _isLoading
                                    ? const Center(
                                        key: ValueKey('loading'),
                                        child: CircularProgressIndicator(
                                          color: AppColors.purple,
                                        ),
                                      )
                                    : _loadError != null
                                    ? _buildLoadError()
                                    : switch (_tabIndex) {
                                        1 => _buildStatsPage(),
                                        2 => _buildSettingsPage(),
                                        _ => _buildHomePage(),
                                      },
                              ),
                            ),
                            _buildBottomBar(),
                          ],
                        ),
                        if (!_isLoading && _loadError == null && _tabIndex == 0)
                          Positioned(
                            right: 24,
                            bottom: 86,
                            child: FloatingActionButton(
                              heroTag: 'addTask',
                              tooltip: 'Add task',
                              onPressed: _addTask,
                              backgroundColor: AppColors.purple,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              child: const Icon(Icons.add_rounded, size: 32),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
