import 'package:flutter/material.dart';
import 'package:flutter_cafe/flutter_cafe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Waffle', () {
    final List<Widget> columnFixtures = [
      SizedBox(width: 100, height: 100, key: Key('1st')),
      SizedBox(width: 100, height: 100, key: Key('2nd')),
      SizedBox(width: 100, height: 100, key: Key('3rd')),
      SizedBox(width: 100, height: 100, key: Key('4th')),
    ];
    final Widget headerFixture =
        SizedBox(key: Key('header'), width: 200, height: 100);
    final Widget footerFixture =
        SizedBox(key: Key('footer'), width: 200, height: 50);

    Future<void> _testColumns() async {
      expect(find.byKey(Key('1st')), findsOneWidget);
      expect(find.byKey(Key('2nd')), findsOneWidget);
      expect(find.byKey(Key('3rd')), findsOneWidget);
      expect(find.byKey(Key('4th')), findsOneWidget);
    }

    Future<void> _testHeaderAndFooter() async {
      expect(find.byKey(Key('header')), findsOneWidget);
      expect(find.byKey(Key('footer')), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Card &&
              w.child is Column &&
              (w.child as Column).children.length == 3,
        ),
        findsOneWidget,
        reason: 'Direct card child is column',
      );
    }

    testWidgets(
      'should display only columns, inside a row, and inside a card',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: Waffle(columns: columnFixtures)),
        ));

        await _testColumns();

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Card &&
                w.child is Row &&
                (w.child as Row).children.whereType<SizedBox>().length == 4,
          ),
          findsOneWidget,
          reason: 'Since no other vertical child, '
              'column row is the direct child of Card',
        );

        expect(find.byType(InkWell), findsNothing);
      },
    );

    testWidgets(
      'should display header and footer',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Waffle(
              header: headerFixture,
              footer: footerFixture,
              columns: columnFixtures,
            ),
          ),
        ));

        await _testColumns();
        await _testHeaderAndFooter();

        expect(find.byType(InkWell), findsNothing);
      },
    );

    testWidgets('should trigger onTap and onLongPress', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Waffle(
            header: headerFixture,
            footer: footerFixture,
            columns: columnFixtures,
            onTap: (_) => print('onTap'),
            onLongPress: (_) => print('onLongPress'),
          ),
        ),
      ));

      await _testColumns();
      await _testHeaderAndFooter();

      await expectLater(
        () async => await tester.tap(find.byType(InkWell)),
        prints('onTap\n'),
      );
      await expectLater(
        () async => await tester.longPress(find.byType(InkWell)),
        prints('onLongPress\n'),
      );
    });
  });
}
