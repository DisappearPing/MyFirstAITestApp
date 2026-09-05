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

  Map<String, Object> toJson({required int position}) => {
    'title': title,
    'description': description,
    'isDone': isDone,
    'position': position,
  };

  factory Todo.fromJson(String id, Map<String, dynamic> json) => Todo(
    id: id,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isDone: json['isDone'] as bool? ?? false,
  );
}
