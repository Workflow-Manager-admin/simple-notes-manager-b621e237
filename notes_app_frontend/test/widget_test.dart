import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app_frontend/main.dart';

void main() {
  testWidgets('App main screen title', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('My Notes'), findsOneWidget);
  });

  // Additional basic widget test example (Home screen has FAB)
  testWidgets('FloatingActionButton exists on Home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
