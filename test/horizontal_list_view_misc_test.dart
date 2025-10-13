// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexible_horizontal_list_view/flexible_horizontal_list_view.dart';

const Key blockKey = Key('test');

void main() {
  testWidgets('Cannot scroll a non-overflowing block', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          key: blockKey,
          children: const <Widget>[
            SizedBox(
              width: 200.0, // less than 800, the width of the test area
              child: Text('Hello'),
            ),
          ],
        ),
      ),
    );

    final Offset middleOfContainer = tester.getCenter(find.text('Hello'));
    final Offset target = tester.getCenter(find.byKey(blockKey));
    final TestGesture gesture = await tester.startGesture(target);
    await gesture.moveBy(const Offset(-10.0, 0.0));

    await tester.pump(const Duration(milliseconds: 1));

    expect(tester.getCenter(find.text('Hello')) == middleOfContainer, isTrue);

    await gesture.up();
  });

  testWidgets('Can scroll an overflowing block', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          key: blockKey,
          children: const <Widget>[
            SizedBox(
              width: 2000.0, // more than 800, the width of the test area
              child: Text('Hello'),
            ),
          ],
        ),
      ),
    );

    final Offset middleOfContainer = tester.getCenter(find.text('Hello'));
    expect(middleOfContainer.dx, equals(1000.0));
    expect(middleOfContainer.dy, equals(7.0));

    final Offset target = tester.getCenter(find.byKey(blockKey));
    final TestGesture gesture = await tester.startGesture(target);
    await gesture.moveBy(const Offset(-10.0, 0.0));

    await tester.pump(); // redo layout

    expect(tester.getCenter(find.text('Hello')), isNot(equals(middleOfContainer)));

    await gesture.up();
  });

  testWidgets('HorizontalListView reverse', (WidgetTester tester) async {
    int first = 0;
    int second = 0;

    Widget buildBlock({bool reverse = false}) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          key: UniqueKey(),
          reverse: reverse,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                first += 1;
              },
              child: Container(
                width: 450.0, // more than half the width of the test area
                height: 600,
                color: const Color(0xFF00FF00),
              ),
            ),
            GestureDetector(
              onTap: () {
                second += 1;
              },
              child: Container(
                width: 450.0, // more than half the width of the test area
                height: 600,
                color: const Color(0xFF0000FF),
              ),
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(buildBlock(reverse: true));

    const Offset target = Offset(200.0, 200.0);
    await tester.tapAt(target);
    expect(first, equals(0));
    expect(second, equals(1));

    await tester.pumpWidget(buildBlock());

    await tester.tapAt(target);
    expect(first, equals(1));
    expect(second, equals(1));
  });

  testWidgets('HorizontalListView controller', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);

    Widget buildBlock() {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          controller: controller,
          children: const <Widget>[Text('A'), Text('B'), Text('C')],
        ),
      );
    }

    await tester.pumpWidget(buildBlock());
    expect(controller.offset, equals(0.0));
  });

  testWidgets('SliverBlockChildListDelegate.estimateMaxScrollOffset hits end', (
    WidgetTester tester,
  ) async {
    final SliverChildListDelegate delegate = SliverChildListDelegate(<Widget>[
      Container(),
      Container(),
      Container(),
      Container(),
      Container(),
    ]);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(slivers: <Widget>[SliverList(delegate: delegate)]),
      ),
    );

    final SliverMultiBoxAdaptorElement element = tester.element(
      find.byType(SliverList, skipOffstage: false),
    );

    final double maxScrollOffset = element.estimateMaxScrollOffset(
      null,
      firstIndex: 3,
      lastIndex: 4,
      leadingScrollOffset: 25.0,
      trailingScrollOffset: 26.0,
    );
    expect(maxScrollOffset, equals(26.0));
  });
}