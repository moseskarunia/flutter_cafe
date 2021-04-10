import 'package:flutter/material.dart';
import 'package:flutter_cafe/flutter_cafe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'should display only columns, inside a row, and inside a card',
    (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Waffle(
            columns: [
              SizedBox(width: 100, height: 100, key: Key('1st')),
              SizedBox(width: 100, height: 100, key: Key('2nd')),
              SizedBox(width: 100, height: 100, key: Key('3rd')),
            ],
          ),
        ),
      ));

      expect(find.byKey(Key('1st')), findsOneWidget);
      expect(find.byKey(Key('2nd')), findsOneWidget);
      expect(find.byKey(Key('3rd')), findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Card &&
              w.child is Row &&
              (w.child as Row).children.whereType<SizedBox>().length == 3,
        ),
        findsOneWidget,
      );

      expect(find.byType(InkWell), findsNothing);
    },
  );

  testWidgets(
    'should display only columns, inside a row, and inside a card',
    (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Waffle(
            columns: [
              SizedBox(width: 100, height: 100, key: Key('1st')),
              SizedBox(width: 100, height: 100, key: Key('2nd')),
              SizedBox(width: 100, height: 100, key: Key('3rd')),
            ],
          ),
        ),
      ));

      expect(find.byKey(Key('1st')), findsOneWidget);
      expect(find.byKey(Key('2nd')), findsOneWidget);
      expect(find.byKey(Key('3rd')), findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Card &&
              w.child is Row &&
              (w.child as Row).children.whereType<SizedBox>().length == 3,
        ),
        findsOneWidget,
      );

      expect(find.byType(InkWell), findsNothing);
    },
  );
}
