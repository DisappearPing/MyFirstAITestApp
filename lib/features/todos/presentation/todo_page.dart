import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_first_app/features/todos/data/models/todo.dart';
import 'package:my_first_app/features/todos/presentation/todo_view_model.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key, required this.viewModel});

  final TodoViewModel viewModel;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.loadTodos());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    await widget.viewModel.addTodo(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今日待辦',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '已完成 ${widget.viewModel.completedCount} / '
                        '${widget.viewModel.totalCount} 件事情',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onSubmitted: (_) {
                                unawaited(_addTodo());
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '例如：閱讀 Flutter 教學',
                                labelText: '新增待辦事項',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () {
                              unawaited(_addTodo());
                            },
                            child: const Text('新增'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount: widget.viewModel.todos.length,
                          onReorder: (oldIndex, newIndex) {
                            unawaited(
                              widget.viewModel.reorderTodos(oldIndex, newIndex),
                            );
                          },
                          itemBuilder: (context, index) {
                            final todo = widget.viewModel.todos[index];
                            return _TodoListItem(
                              key: ValueKey(todo.id),
                              todo: todo,
                              index: index,
                              onDoneChanged: (isDone) {
                                unawaited(
                                  widget.viewModel.setTodoDone(todo.id, isDone),
                                );
                              },
                              onDelete: () {
                                unawaited(widget.viewModel.deleteTodo(todo.id));
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TodoListItem extends StatelessWidget {
  const _TodoListItem({
    super.key,
    required this.todo,
    required this.index,
    required this.onDoneChanged,
    required this.onDelete,
  });

  final Todo todo;
  final int index;
  final ValueChanged<bool> onDoneChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_indicator,
                semanticLabel: '拖曳排序',
              ),
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
