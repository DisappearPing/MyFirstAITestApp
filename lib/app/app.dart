import 'package:flutter/material.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '今日待辦',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3454D1)),
        useMaterial3: true,
      ),
      home: home,
    );
  }
}
