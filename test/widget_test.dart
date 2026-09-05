import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/app/app.dart';
import 'package:my_first_app/features/todos/data/repositories/in_memory_todo_repository.dart';
import 'package:my_first_app/features/todos/presentation/pages/todo_list_page.dart';
import 'package:my_first_app/features/todos/presentation/view_models/todo_list_view_model.dart';

void main() {
  test('reordering todos updates the repository source of truth', () async {
    final repository = InMemoryTodoRepository();
    final viewModel = TodoListViewModel(repository);

    await viewModel.loadTodos();
    await viewModel.reorderTodos(0, 3);

    expect(viewModel.todos.last.id, 'welcome-1');
    expect((await repository.getTodos()).last.id, 'welcome-1');
  });

  test('updating a todo stores its title and description', () async {
    final repository = InMemoryTodoRepository();
    final viewModel = TodoListViewModel(repository);

    await viewModel.loadTodos();
    await viewModel.updateTodo(
      id: 'welcome-1',
      title: '完成登入功能',
      description: '先完成 Google 與 Email 登入。',
    );

    final todo = (await repository.getTodos()).first;
    expect(todo.title, '完成登入功能');
    expect(todo.description, '先完成 Google 與 Email 登入。');
  });

  testWidgets('shows the initial todo list', (tester) async {
    await tester.pumpWidget(
      TodoApp(
        home: TodoListPage(
          viewModel: TodoListViewModel(InMemoryTodoRepository()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('今日待辦'), findsOneWidget);
    expect(find.text('已完成 0 / 3 件事情'), findsOneWidget);
  });
}
