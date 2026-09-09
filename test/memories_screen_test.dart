import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careconnect_swen661/screens/memories_screen.dart';

void main() {
  testWidgets('MemoriesScreen renders memories and accessibility semantics', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MemoriesScreen()));

    // Verify screen title and memory card items render
    expect(find.text('Memories'), findsOneWidget);
    expect(find.text('Family Picnic'), findsOneWidget);
    expect(find.text('Birthday Celebration'), findsOneWidget);

    // Verify Semantics wrapper is present
    expect(find.byType(Semantics), findsWidgets);
  });
}