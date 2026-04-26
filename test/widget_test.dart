import 'package:flutter_test/flutter_test.dart';
import 'package:medsafe/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedsafeApp());
    await tester.pump();
    expect(find.byType(MedsafeApp), findsOneWidget);
  });
}
