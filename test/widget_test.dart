import 'package:flutter_test/flutter_test.dart';
import 'package:ble_scale_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(onboardingDone: false));
    await tester.pumpAndSettle();
    // просто проверяем, что приложение запускается без ошибок
  });
}