import 'package:flutter_test/flutter_test.dart';
import 'package:student_registration_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentRegistrationApp());

    // Verify app starts without crashing
    expect(find.byType(StudentRegistrationApp), findsOneWidget);
  });
}
