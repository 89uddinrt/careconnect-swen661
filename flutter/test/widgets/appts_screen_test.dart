import 'package:careconnect_mobile/screens/appointments/appts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ApptsScreen renders appointments and checks semantics', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ApptsScreen()));

    // Verify titles and data render correctly
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Dr. Smith'), findsOneWidget);
    expect(find.textContaining('Cardiology Checkup'), findsOneWidget);
    expect(find.text('Dr. Davis'), findsOneWidget);

    // Verify Semantics wrapper is present for accessibility
    expect(find.byType(Semantics), findsWidgets);
  });
}
