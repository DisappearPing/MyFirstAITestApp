import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_first_app/features/todos/domain/models/todo.dart';
import 'package:my_first_app/features/todos/presentation/pages/todo_editor_page.dart';
import 'package:my_first_app/features/todos/presentation/view_models/todo_list_view_model.dart';
import 'package:my_first_app/features/todos/presentation/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({
    super.key,
    required this.viewModel,
    this.userEmail,
    this.isGuest = false,
    this.onSignOut,
    this.onOpenAccount,
  });

  final TodoListViewModel viewModel;
  final String? userEmail;
  final bool isGuest;
  final VoidCallback? onSignOut;
  final VoidCallback? onOpenAccount;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
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

  Future<void> _openEditor([Todo? todo]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TodoEditorPage(
          todo: todo,
          onSave: (title, description) async {
            if (todo == null) {
              await widget.viewModel.addTodo(title, description: description);
            } else {
              await widget.viewModel.updateTodo(
                id: todo.id,
                title: title,
                description: description,
              );
            }
          },
        ),
      ),
    );
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '今日待辦',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ),
                          if (widget.isGuest && widget.onOpenAccount != null)
                            FilledButton.tonalIcon(
                              onPressed: widget.onOpenAccount,
                              icon: const Icon(Icons.login),
                              label: const Text('建立帳號'),
                            )
                          else if (widget.onOpenAccount != null)
                            IconButton(
                              tooltip: '會員中心',
                              onPressed: widget.onOpenAccount,
                              icon: const Icon(Icons.account_circle_outlined),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('已完成 ${widget.viewModel.completedCount} / ${widget.viewModel.totalCount} 件事情'),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onSubmitted: (_) => unawaited(_addTodo()),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '例如：閱讀 Flutter 教學',
                                labelText: '新增待辦事項',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () => unawaited(_addTodo()),
                            child: const Text('新增'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => unawaited(_openEditor()),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('新增含詳細內容的待辦'),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount: widget.viewModel.todos.length,
                          onReorder: (oldIndex, newIndex) => unawaited(
                            widget.viewModel.reorderTodos(oldIndex, newIndex),
                          ),
                          itemBuilder: (context, index) {
                            final todo = widget.viewModel.todos[index];
                            return TodoListItem(
                              key: ValueKey(todo.id),
                              todo: todo,
                              index: index,
                              onDoneChanged: (isDone) => unawaited(widget.viewModel.setTodoDone(todo.id, isDone)),
                              onDelete: () => unawaited(widget.viewModel.deleteTodo(todo.id)),
                              onTap: () => unawaited(_openEditor(todo)),
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
