// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:scrum_poker_mobile/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, __) => const MaterialPage(child: Text('Home')),
        ),
      ],
    );
    await tester.pumpWidget(ScrumPokerApp(router: router));
    await tester.pump();

    expect(find.text('Scrum Poker'), findsOneWidget);
  });
}
