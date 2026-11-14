import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the task dashboard and summary', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.text('Finish Flutter project'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));
    expect(find.text('You have 4 tasks today'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.byTooltip('Add task'), findsOneWidget);
  });

  testWidgets('adds a task and updates the dashboard', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Test new task');
    final dueField = tester.widget<TextFormField>(
      find.byType(TextFormField).last,
    );
    expect(dueField.controller!.text, startsWith('Today, '));
    await tester.tap(find.text('Add task').last);
    await tester.pumpAndSettle();

    expect(find.text('Test new task'), findsOneWidget);
    final timePeriod = DateTime.now().hour < 12 ? 'AM' : 'PM';
    expect(find.textContaining(timePeriod), findsWidgets);
    expect(find.text('You have 5 tasks today'), findsOneWidget);
  });

  testWidgets('Today filter uses task creation date', (tester) async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    SharedPreferences.setMockInitialValues({
      'taskflow_data': jsonEncode({
        'notificationsEnabled': true,
        'tasks': [
          {
            'title': 'Created today',
            'due': 'Today, 9:00 AM',
            'createdAt': now.toIso8601String(),
            'category': 'Personal',
            'priority': false,
            'completed': false,
          },
          {
            'title': 'Created yesterday',
            'due': 'Today, 9:00 AM',
            'createdAt': yesterday.toIso8601String(),
            'category': 'Personal',
            'priority': false,
            'completed': false,
          },
        ],
      }),
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('Created today'), findsOneWidget);
    expect(find.text('Created yesterday'), findsNothing);
  });

  testWidgets('shows AM/PM without clipping on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final createdAt = DateTime(2026, 11, 10, 22, 51);
    SharedPreferences.setMockInitialValues({
      'taskflow_data': jsonEncode({
        'notificationsEnabled': true,
        'tasks': [
          {
            'title': 'Evening task',
            'due': 'Today, 9:00 AM',
            'createdAt': createdAt.toIso8601String(),
            'category': 'Personal',
            'priority': false,
            'completed': false,
          },
        ],
      }),
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final timestamp = find.text('11/10 10:51 PM');
    expect(timestamp, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(timestamp);
    expect(paragraph.didExceedMaxLines, isFalse);
  });

  testWidgets('adds a creation date when loading legacy tasks', (tester) async {
    SharedPreferences.setMockInitialValues({
      'taskflow_data': jsonEncode({
        'notificationsEnabled': true,
        'tasks': [
          {
            'title': 'Legacy task',
            'due': 'Today, 9:00 AM',
            'category': 'Personal',
            'priority': false,
            'completed': false,
          },
        ],
      }),
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    final savedData = jsonDecode(preferences.getString('taskflow_data')!);
    final savedTask = (savedData['tasks'] as List<dynamic>).single;
    expect(savedTask['createdAt'], isA<String>());
  });

  testWidgets('completes tasks and filters the completed list', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mark complete').first);
    await tester.pumpAndSettle();
    final completedFilter = find.text('Completed').last;
    await tester.ensureVisible(completedFilter);
    await tester.pumpAndSettle();
    await tester.tap(completedFilter);
    await tester.pumpAndSettle();

    expect(find.text('Finish Flutter project'), findsOneWidget);
    expect(find.text('Read Dart documentation'), findsOneWidget);
    expect(find.text('Go for a walk'), findsNothing);
  });

  testWidgets('deleted tasks stay deleted after the app is recreated', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Task options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();
    expect(find.text('Finish Flutter project'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Finish Flutter project'), findsNothing);
  });

  testWidgets('delete undo is available briefly and then expires', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Task options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();

    expect(find.text('UNDO'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('UNDO'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('UNDO'), findsNothing);
    expect(find.text('Finish Flutter project'), findsNothing);
  });

  testWidgets('delete can be undone before the timeout', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Task options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(find.text('Finish Flutter project'), findsOneWidget);
  });

  testWidgets('notification bell opens an interactive reminder center', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Your unfinished tasks are listed here.'), findsOneWidget);
    expect(find.text('Finish Flutter project'), findsNWidgets(2));
    expect(
      find.text('In-app reminders are shown while TaskFlow is open.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Reminder settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Reminders are paused.'), findsOneWidget);
    await tester.tap(find.text('Turn on reminders'));
    await tester.pumpAndSettle();
    expect(find.text('Your unfinished tasks are listed here.'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Done').first);
    await tester.pumpAndSettle();
    expect(find.text('Finish Flutter project'), findsOneWidget);
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    expect(find.text('Reminders'), findsNothing);
  });

  testWidgets('due time opens the clock picker instead of text entry', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Choose time'));
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
  });

  testWidgets('switches between stats and settings on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Your progress'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Make TaskFlow work for you.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home content scrolls on short screens', (tester) async {
    tester.view.physicalSize = const Size(360, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final homeScroll = find.byKey(const ValueKey('home'));
    final scrollable = find
        .descendant(of: homeScroll, matching: find.byType(Scrollable))
        .first;
    final position = tester.state<ScrollableState>(scrollable).position;
    await tester.drag(homeScroll, const Offset(0, -250));
    await tester.pumpAndSettle();

    expect(position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
