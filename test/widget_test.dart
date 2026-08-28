import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('shows the initial todo list', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('今日待辦'), findsOneWidget);
    expect(find.text('已完成 0 / 3 件事情'), findsOneWidget);
  });
}
