import 'package:flutter/widgets.dart';
import 'package:my_first_app/app/app.dart';
import 'package:my_first_app/features/todos/data/repositories/in_memory_todo_repository.dart';
import 'package:my_first_app/features/todos/presentation/view_models/todo_list_view_model.dart';

void main() {
  final repository = InMemoryTodoRepository();
  final viewModel = TodoListViewModel(repository);

  runApp(TodoApp(viewModel: viewModel));
}
