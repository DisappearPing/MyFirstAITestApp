import 'package:flutter/foundation.dart';
import 'package:my_first_app/features/todos/data/repositories/todo_repository.dart';
import 'package:my_first_app/features/todos/domain/models/todo.dart';

class TodoListViewModel extends ChangeNotifier {
  TodoListViewModel(this._repository);

  final TodoRepository _repository;
  List<Todo> _todos = [];
  bool _isLoading = false;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get completedCount => _todos.where((todo) => todo.isDone).length;
  int get totalCount => _todos.length;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todos = await _repository.getTodos();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String title, {String description = ''}) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    _todos = [
      ..._todos,
      Todo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: trimmedTitle,
        description: description.trim(),
      ),
    ];
    await _saveAndNotify();
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    required String description,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    _todos = _todos
        .map((todo) => todo.id == id
            ? todo.copyWith(title: trimmedTitle, description: description.trim())
            : todo)
        .toList();
    await _saveAndNotify();
  }

  Future<void> setTodoDone(String id, bool isDone) async {
    _todos = _todos
        .map((todo) => todo.id == id ? todo.copyWith(isDone: isDone) : todo)
        .toList();
    await _saveAndNotify();
  }

  Future<void> deleteTodo(String id) async {
    _todos = _todos.where((todo) => todo.id != id).toList();
    await _saveAndNotify();
  }

  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final reorderedTodos = List<Todo>.of(_todos);
    final todo = reorderedTodos.removeAt(oldIndex);
    reorderedTodos.insert(newIndex, todo);
    _todos = reorderedTodos;
    await _saveAndNotify();
  }

  Future<void> _saveAndNotify() async {
    await _repository.saveTodos(_todos);
    notifyListeners();
  }
}
