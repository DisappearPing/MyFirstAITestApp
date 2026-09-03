import 'package:my_first_app/features/todos/data/models/todo.dart';

abstract interface class TodoRepository {
  Future<List<Todo>> getTodos();

  Future<void> saveTodos(List<Todo> todos);
}
