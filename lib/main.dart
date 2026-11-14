import 'package:flutter/material.dart';
import 'package:todo_app/screens/todo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF713BFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const ToDoScreen(),
    );
  }
}
