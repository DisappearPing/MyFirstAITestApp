import 'package:flutter/material.dart';
import 'package:my_first_app/features/todos/presentation/todo_page.dart';
import 'package:my_first_app/features/todos/presentation/todo_view_model.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.viewModel});

  final TodoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '今日待辦',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3454D1)),
        useMaterial3: true,
      ),
      home: TodoPage(viewModel: viewModel),
    );
  }
}
