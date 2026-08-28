import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '今日待辦',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3454D1)),
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

class Todo {
  Todo(this.title, {this.done = false});

  final String title;
  bool done;
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _controller = TextEditingController();
  final List<Todo> _todos = [
    Todo('完成第一個 Flutter 網頁'),
    Todo('試著新增一項待辦'),
    Todo('點選核取方塊完成任務'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTodo() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _todos.add(Todo(title));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = _todos.where((todo) => todo.done).length;

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
                  Text('今日待辦', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text('已完成 $completed / ${_todos.length} 件事情'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _addTodo(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '例如：閱讀 Flutter 教學',
                            labelText: '新增待辦事項',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _addTodo,
                        child: const Text('新增'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _todos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final todo = _todos[index];
                        return Card(
                          child: CheckboxListTile(
                            value: todo.done,
                            onChanged: (value) {
                              setState(() => todo.done = value ?? false);
                            },
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            secondary: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: '刪除',
                              onPressed: () =>
                                  setState(() => _todos.removeAt(index)),
                            ),
                          ),
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
  }
}
