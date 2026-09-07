import 'dart:typed_data';

class TodoImage {
  const TodoImage({required this.path, required this.url});

  final String path;
  final String url;
}

class TodoImageUpload {
  const TodoImageUpload({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;
}
