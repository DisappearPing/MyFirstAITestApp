import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_first_app/features/todos/data/repositories/todo_image_repository.dart';
import 'package:my_first_app/features/todos/domain/models/todo_image.dart';

class FirebaseStorageTodoImageRepository implements TodoImageRepository {
  FirebaseStorageTodoImageRepository({
    required this.userId,
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final String userId;
  final FirebaseStorage _storage;

  @override
  Future<TodoImage> uploadImage({
    required String todoId,
    required TodoImageUpload image,
  }) async {
    final extension = switch (image.contentType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final path = 'users/$userId/todos/$todoId/photo-$timestamp.$extension';
    final reference = _storage.ref(path);
    await reference.putData(
      image.bytes,
      SettableMetadata(contentType: image.contentType),
    );
    return TodoImage(path: path, url: await reference.getDownloadURL());
  }

  @override
  Future<void> deleteImage(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}
