import 'package:flutter/foundation.dart';
import 'package:my_first_app/features/todos/data/repositories/todo_image_repository.dart';
import 'package:my_first_app/features/todos/data/repositories/todo_repository.dart';
import 'package:my_first_app/features/todos/domain/models/todo.dart';
import 'package:my_first_app/features/todos/domain/models/todo_image.dart';

class TodoListViewModel extends ChangeNotifier {
  TodoListViewModel(this._repository, {TodoImageRepository? imageRepository})
    : _imageRepository = imageRepository;

  final TodoRepository _repository;
  final TodoImageRepository? _imageRepository;
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

  Future<void> addTodo(
    String title, {
    String description = '',
    TodoImageUpload? image,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final uploadedImage = await _uploadImage(id, image);
    _todos = [
      ..._todos,
      Todo(
        id: id,
        title: trimmedTitle,
        description: description.trim(),
        imageUrl: uploadedImage?.url,
        imagePath: uploadedImage?.path,
      ),
    ];
    await _saveAndNotify();
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    required String description,
    TodoImageUpload? newImage,
    bool removeImage = false,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    final currentTodo = _todos.firstWhere((todo) => todo.id == id);
    final uploadedImage = await _uploadImage(id, newImage);
    _todos = _todos
        .map((todo) => todo.id == id
            ? todo.copyWith(
                title: trimmedTitle,
                description: description.trim(),
                imageUrl: uploadedImage?.url,
                imagePath: uploadedImage?.path,
                clearImage: removeImage,
              )
            : todo)
        .toList();
    await _saveAndNotify();
    if ((removeImage || uploadedImage != null) && currentTodo.imagePath != null) {
      await _imageRepository?.deleteImage(currentTodo.imagePath!);
    }
  }

  Future<void> setTodoDone(String id, bool isDone) async {
    _todos = _todos
        .map((todo) => todo.id == id ? todo.copyWith(isDone: isDone) : todo)
        .toList();
    await _saveAndNotify();
  }

  Future<void> deleteTodo(String id) async {
    final deletedTodo = _todos.firstWhere((todo) => todo.id == id);
    _todos = _todos.where((todo) => todo.id != id).toList();
    await _saveAndNotify();
    if (deletedTodo.imagePath != null) {
      await _imageRepository?.deleteImage(deletedTodo.imagePath!);
    }
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

  Future<TodoImage?> _uploadImage(
    String todoId,
    TodoImageUpload? image,
  ) async {
    if (image == null) return null;
    if (image.bytes.length > 5 * 1024 * 1024) {
      throw ArgumentError('圖片大小不可超過 5 MB。');
    }
    final repository = _imageRepository;
    if (repository == null) {
      throw StateError('圖片服務尚未設定。');
    }
    return repository.uploadImage(todoId: todoId, image: image);
  }
}
