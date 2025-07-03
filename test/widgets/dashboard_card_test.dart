import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/widgets/dashboard_card.dart';

void main() {
  group('DashboardCard Widget Tests', () {
    testWidgets('should display title and value correctly', (tester) async {
      const title = 'Total Invoices';
      const value = '42';
      const icon = Icons.receipt;
      const color = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              title: title,
              value: value,
              icon: icon,
              color: color,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(value), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('should show arrow icon when onTap is provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              title: 'Test Card',
              value: '100',
              icon: Icons.analytics,
              color: Colors.green,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      
      await tester.tap(find.byType(DashboardCard));
      await tester.pump();
      
      expect(tapped, true);
    });

    testWidgets('should not show arrow icon when onTap is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              title: 'Test Card',
              value: '100',
              icon: Icons.analytics,
              color: Colors.green,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    });
  });
} 