class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
  });

  final String id;
  final String title;
  final String description;
  final bool isDone;

  Todo copyWith({String? title, String? description, bool? isDone}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }
}
