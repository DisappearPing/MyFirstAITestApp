import 'package:my_first_app/features/todos/domain/models/todo_image.dart';

abstract interface class TodoImageRepository {
  Future<TodoImage> uploadImage({
    required String todoId,
    required TodoImageUpload image,
  });

  Future<void> deleteImage(String path);
}
