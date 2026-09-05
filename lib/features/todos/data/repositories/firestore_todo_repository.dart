import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_first_app/features/todos/data/repositories/todo_repository.dart';
import 'package:my_first_app/features/todos/domain/models/todo.dart';

class FirestoreTodoRepository implements TodoRepository {
  FirestoreTodoRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _todos => _firestore
      .collection('users')
      .doc(userId)
      .collection('todos');

  @override
  Future<List<Todo>> getTodos() async {
    final snapshot = await _todos.orderBy('position').get();
    return snapshot.docs
        .map((document) => Todo.fromJson(document.id, document.data()))
        .toList();
  }

  @override
  Future<void> saveTodos(List<Todo> todos) async {
    final existing = await _todos.get();
    final todoIds = todos.map((todo) => todo.id).toSet();
    final batch = _firestore.batch();

    for (final document in existing.docs) {
      if (!todoIds.contains(document.id)) batch.delete(document.reference);
    }
    for (var index = 0; index < todos.length; index++) {
      final todo = todos[index];
      batch.set(_todos.doc(todo.id), todo.toJson(position: index));
    }
    await batch.commit();
  }
}
