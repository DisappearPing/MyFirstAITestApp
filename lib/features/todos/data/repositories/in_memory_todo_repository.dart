import 'package:my_first_app/features/todos/domain/models/todo.dart';
import 'package:my_first_app/features/todos/data/repositories/todo_repository.dart';

class InMemoryTodoRepository implements TodoRepository {
  InMemoryTodoRepository({List<Todo>? initialTodos})
      : _todos = List.of(initialTodos ?? _defaultTodos);

  static const _defaultTodos = [
    Todo(id: 'welcome-1', title: '完成第一個 Flutter 網頁'),
    Todo(id: 'welcome-2', title: '試著新增一項待辦'),
    Todo(id: 'welcome-3', title: '點選核取方塊完成任務'),
  ];

  List<Todo> _todos;

  @override
  Future<List<Todo>> getTodos() async => List.unmodifiable(_todos);

  @override
  Future<void> saveTodos(List<Todo> todos) async {
    _todos = List.of(todos);
  }
}
