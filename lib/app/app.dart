import 'package:flutter/material.dart';
import 'package:my_first_app/features/todos/presentation/pages/todo_list_page.dart';
import 'package:my_first_app/features/todos/presentation/view_models/todo_list_view_model.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.viewModel});

  final TodoListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '今日待辦',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3454D1)),
        useMaterial3: true,
      ),
      home: TodoListPage(viewModel: viewModel),
    );
  }
}
