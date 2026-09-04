import 'package:flutter/material.dart';
import 'package:my_first_app/features/todos/domain/models/todo.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.index,
    required this.onDoneChanged,
    required this.onDelete,
    required this.onTap,
  });

  final Todo todo;
  final int index;
  final ValueChanged<bool> onDoneChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (value) => onDoneChanged(value ?? false),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: todo.description.isEmpty
            ? const Text('點一下可加入詳細描述')
            : Text(
                todo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_indicator, semanticLabel: '拖曳排序'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '刪除',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
