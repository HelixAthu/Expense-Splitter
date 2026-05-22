// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_splitter/main.dart';

void main() {
  testWidgets('renders the expense splitter shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExpenseSplitterApp());

    expect(find.text('Expense Splitter'), findsOneWidget);
    expect(find.text('Add Expense'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Summary'), findsWidgets);

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to settle yet'), findsOneWidget);
  });
}
