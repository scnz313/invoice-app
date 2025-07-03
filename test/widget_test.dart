// Basic Flutter widget test for Invoice App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:invoice_app/main.dart';

void main() {
  testWidgets('Invoice app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InvoiceApp());
    
    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that our app loads successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Check for some common dashboard elements
    final textWidgets = find.byType(Text);
    expect(textWidgets, findsAtLeastNWidgets(1));
  });
}
