import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/app.dart';
import 'package:my_first_app/features/todos/data/repositories/in_memory_todo_repository.dart';
import 'package:my_first_app/features/todos/presentation/todo_view_model.dart';

void main() {
  test('reordering todos updates the repository source of truth', () async {
    final repository = InMemoryTodoRepository();
    final viewModel = TodoViewModel(repository);

    await viewModel.loadTodos();
    await viewModel.reorderTodos(0, 3);

    expect(viewModel.todos.last.id, 'welcome-1');
    expect((await repository.getTodos()).last.id, 'welcome-1');
  });

  testWidgets('shows the initial todo list', (tester) async {
    await tester.pumpWidget(
      TodoApp(viewModel: TodoViewModel(InMemoryTodoRepository())),
    );
    await tester.pump();

    expect(find.text('今日待辦'), findsOneWidget);
    expect(find.text('已完成 0 / 3 件事情'), findsOneWidget);
  });
}
