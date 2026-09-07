class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    this.imageUrl,
    this.imagePath,
  });

  final String id;
  final String title;
  final String description;
  final bool isDone;
  final String? imageUrl;
  final String? imagePath;

  Todo copyWith({
    String? title,
    String? description,
    bool? isDone,
    String? imageUrl,
    String? imagePath,
    bool clearImage = false,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      imageUrl: clearImage ? null : imageUrl ?? this.imageUrl,
      imagePath: clearImage ? null : imagePath ?? this.imagePath,
    );
  }

  Map<String, Object> toJson({required int position}) => {
    'title': title,
    'description': description,
    'isDone': isDone,
    if (imageUrl != null) 'imageUrl': imageUrl!,
    if (imagePath != null) 'imagePath': imagePath!,
    'position': position,
  };

  factory Todo.fromJson(String id, Map<String, dynamic> json) => Todo(
    id: id,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isDone: json['isDone'] as bool? ?? false,
    imageUrl: json['imageUrl'] as String?,
    imagePath: json['imagePath'] as String?,
  );
}
