import 'package:flutter_test/flutter_test.dart';
import 'package:naqsh_ai/main.dart';

void main() {
  testWidgets('app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const NaqshApp());
    expect(find.text('NAQSH AI'), findsOneWidget);
  });
}
