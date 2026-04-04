import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:light/main.dart';
import 'package:light/services/app_state.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const LightApp(),
      ),
    );
    expect(find.text('Light'), findsOneWidget);
  });
}
