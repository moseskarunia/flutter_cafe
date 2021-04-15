import 'package:flutter/material.dart';
import 'package:flutter_cafe/flutter_cafe.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContext extends Fake implements BuildContext {}

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
                (w.child as Row).crossAxisAlignment ==
                    CrossAxisAlignment.start &&
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

  group('WaffleTopping', () {
    testWidgets('should contain title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: WaffleTopping(title: Text('Topping title'))),
      ));

      expect(find.text('Topping title'), findsOneWidget);
      expect(
        find.byType(Container),
        findsNothing,
        reason: 'because width is null',
      );
      expect(
        find.byType(Column),
        findsNothing,
        reason: 'because only title is provided',
      );
    });
    testWidgets('should contain title and content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WaffleTopping(
            title: Text('Topping title'),
            content: Text('Topping content'),
          ),
        ),
      ));

      expect(find.text('Topping title'), findsOneWidget);
      expect(find.text('Topping content'), findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Column && w.crossAxisAlignment == CrossAxisAlignment.start,
        ),
        findsOneWidget,
        reason: 'because only caption is provided',
      );
    });
    testWidgets(
      'should be wrapped with container if width is provided',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: WaffleTopping(title: Text('Topping title'), width: 200),
          ),
        ));

        expect(find.text('Topping title'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
              (w) => w is Container && w.constraints!.maxWidth == 200),
          findsOneWidget,
          reason: 'because width is provided',
        );
      },
    );

    testWidgets(
      'should be wrapped with container if margin or padding is provided',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: WaffleTopping(
              title: Text('Topping title'),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ));

        expect(find.text('Topping title'), findsOneWidget);
        expect(
          find.byWidgetPredicate((w) =>
              w is Container &&
              w.padding == const EdgeInsets.all(16) &&
              w.margin == const EdgeInsets.all(8)),
          findsOneWidget,
          reason: 'even if width not provied, either padding or margin is',
        );
      },
    );

    group('WaffleTopping.asTitleAndColumnOfIconAndCaptions', () {
      test(
        "should throw AssertionError when icons and contentTexts "
        "doesn't have identical length",
        () async {
          await expectLater(
            () => WaffleTopping.asTitleAndColumnOfIconAndCaptions(
                context: FakeContext(),
                titleText: 'abc',
                icons: [Icon(Icons.person)],
                contentTexts: []),
            throwsA(isA<AssertionError>()),
          );
        },
      );

      testWidgets(
        'should create WaffleTopping with title text John Doe, '
        'and 2 content rows: Icons.email - johndoe@test.com & '
        'Icons.home - Sesame Street 123 & Icons.cake - 1st Jan 21',
        (tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: Builder(builder: (context) {
                return WaffleTopping.asTitleAndColumnOfIconAndCaptions(
                  context: context,
                  titleText: 'John Doe',
                  icons: [
                    Icon(Icons.email),
                    Icon(Icons.home),
                    Icon(Icons.cake),
                  ],
                  contentTexts: [
                    'johndoe@test.com',
                    'Sesame Street 123',
                    '1st Jan 21',
                  ],
                );
              }),
            ),
          ));
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Padding &&
                  w.child is Text &&
                  (w.child as Text).data == 'John Doe' &&
                  w.padding == const EdgeInsets.only(bottom: 8),
            ),
            findsOneWidget,
            reason: 'Title is John Doe and has bottom padding 8',
          );
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Text &&
                  w.data == 'John Doe' &&
                  w.style!.fontSize == 14 &&
                  w.style!.fontWeight == FontWeight.w400,
            ),
            findsOneWidget,
            reason: 'Title styled with bodyText2',
          );

          expect(
            find.byWidgetPredicate(
              (w) => w is Column && w.children.length == 3,
            ),
            findsOneWidget,
            reason: 'A column containing 3 children',
          );

          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Row &&
                  w.children.isNotEmpty &&
                  w.children[0] is Icon &&
                  (w.children[0] as Icon).icon == Icons.email &&
                  w.children[1] is SizedBox &&
                  (w.children[1] as SizedBox).width == 16 &&
                  w.children[2] is Expanded &&
                  ((w.children[2] as Expanded).child as Text).data ==
                      'johndoe@test.com' &&
                  ((w.children[2] as Expanded).child as Text).style!.fontSize ==
                      12 &&
                  ((w.children[2] as Expanded).child as Text)
                          .style!
                          .fontWeight ==
                      FontWeight.w400,
            ),
            findsOneWidget,
            reason: 'A row containing Icons.email & 16-width sized box & '
                'caption-styled text',
          );

          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Row &&
                  w.children.isNotEmpty &&
                  w.children[0] is Icon &&
                  (w.children[0] as Icon).icon == Icons.home &&
                  w.children[1] is SizedBox &&
                  (w.children[1] as SizedBox).width == 16 &&
                  w.children[2] is Expanded &&
                  ((w.children[2] as Expanded).child as Text).data ==
                      'Sesame Street 123' &&
                  ((w.children[2] as Expanded).child as Text).style!.fontSize ==
                      12 &&
                  ((w.children[2] as Expanded).child as Text)
                          .style!
                          .fontWeight ==
                      FontWeight.w400,
            ),
            findsOneWidget,
            reason: 'A row containing Icons.home & 16-width sized box & '
                'caption-styled text',
          );

          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Row &&
                  w.children.isNotEmpty &&
                  w.children[0] is Icon &&
                  (w.children[0] as Icon).icon == Icons.cake &&
                  w.children[1] is SizedBox &&
                  (w.children[1] as SizedBox).width == 16 &&
                  w.children[2] is Expanded &&
                  ((w.children[2] as Expanded).child as Text).data ==
                      '1st Jan 21' &&
                  ((w.children[2] as Expanded).child as Text).style!.fontSize ==
                      12 &&
                  ((w.children[2] as Expanded).child as Text)
                          .style!
                          .fontWeight ==
                      FontWeight.w400,
            ),
            findsOneWidget,
            reason: 'A row containing Icons.cake & 16-width sized box & '
                'caption-styled text',
          );
        },
      );

      testWidgets(
        'should find margin, padding and width',
        (tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: Builder(builder: (context) {
                return WaffleTopping.asTitleAndColumnOfIconAndCaptions(
                  context: context,
                  titleText: 'John Doe',
                  icons: [Icon(Icons.email)],
                  contentTexts: ['johndoe@test.com'],
                  margin: const EdgeInsets.all(17),
                  padding: const EdgeInsets.all(19),
                  width: 102,
                );
              }),
            ),
          ));

          await tester.pumpAndSettle();

          expect(
            find.byWidgetPredicate((w) =>
                w is Container &&
                w.constraints!.maxWidth == 102 &&
                w.margin == const EdgeInsets.all(17) &&
                w.padding == const EdgeInsets.all(19)),
            findsOneWidget,
          );
        },
      );
    });
  });

  group('WaffleFlavorRow', () {
    testWidgets(
      'should display 3 color pills with border radius and 16 spacing',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: WaffleFlavorRow(
              color: [Colors.black, Colors.black, Colors.black],
              spacingBetweenColors: 8,
            ),
          ),
        ));

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).color == Colors.black &&
                (w.decoration as BoxDecoration).borderRadius ==
                    BorderRadius.circular(4) &&
                w.constraints!.maxWidth == 32 &&
                w.constraints!.maxHeight == 8,
          ),
          findsNWidgets(3),
        );

        expect(
          find.byWidgetPredicate((w) => w is SizedBox && w.width == 8),
          findsNWidgets(2),
        );

        expect(
          find.byWidgetPredicate(
              (w) => w is Wrap && w.direction == Axis.horizontal),
          findsOneWidget,
        );

        expect(
          find.byWidgetPredicate((w) => w is Container && w.child is Wrap),
          findsNothing,
          reason:
              'No outer container because neither margin nor padding provided',
        );
      },
    );

    testWidgets(
      'should display 3 color pills with border radius and 16 spacing and have '
      'wrapped with container with margin and padding',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: WaffleFlavorRow(
              color: [Colors.black, Colors.black, Colors.black],
              spacingBetweenColors: 8,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ));

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).color == Colors.black &&
                (w.decoration as BoxDecoration).borderRadius ==
                    BorderRadius.circular(4) &&
                w.constraints!.maxWidth == 32 &&
                w.constraints!.maxHeight == 8,
          ),
          findsNWidgets(3),
        );

        expect(
          find.byWidgetPredicate((w) => w is SizedBox && w.width == 8),
          findsNWidgets(2),
        );

        expect(
          find.byWidgetPredicate(
              (w) => w is Wrap && w.direction == Axis.horizontal),
          findsOneWidget,
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.child is Wrap &&
                w.padding == const EdgeInsets.all(8) &&
                w.margin == const EdgeInsets.all(16),
          ),
          findsOneWidget,
          reason:
              'No outer container because neither margin nor padding provided',
        );
      },
    );
  });
}
