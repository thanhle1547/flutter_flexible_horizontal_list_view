// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexible_horizontal_list_view/src/horizontal_list_view.dart';

class TestItem extends StatelessWidget {
  const TestItem({ super.key, required this.item, this.width });
  final int item;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      alignment: Alignment.center,
      child: Text('Item $item', textDirection: TextDirection.ltr),
    );
  }
}

Widget buildFrame({ int? count, double? width, Key? prototypeKey }) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: HorizontalListView.custom(
      prototypeItem: TestItem(item: -1, width: width, key: prototypeKey),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => TestItem(item: index),
        childCount: count,
      ),
    ),
  );
}

void main() {
  testWidgets('HorizontalListView horizontal scrolling basics', (WidgetTester tester) async {
    await tester.pumpWidget(buildFrame(count: 20, width: 100.0));

    // The viewport is 800 pixels wide, lazily created items are 100 pixels wide.
    for (int i = 0; i < 8; i += 1) {
      final Finder item = find.widgetWithText(Container, 'Item $i');
      expect(item, findsOneWidget);
      expect(tester.getTopLeft(item).dx, i * 100.0);
      expect(tester.getSize(item).width, 100.0);
    }
    for (int i = 9; i < 20; i += 1) {
      expect(find.text('Item $i'), findsNothing);
    }

    // Fling scroll to the end.
    await tester.fling(find.text('Item 3'), const Offset(-200.0, 0.0), 5000.0);
    await tester.pumpAndSettle();

    for (int i = 19; i >= 12; i -= 1) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    for (int i = 11; i >= 0; i -= 1) {
      expect(find.text('Item $i'), findsNothing);
    }
  });

  testWidgets('HorizontalListView change the prototype item', (WidgetTester tester) async {
    await tester.pumpWidget(buildFrame(count: 10, width: 80.0));

    // The viewport is 800 pixels wide, each of the 10 items is 80 pixels wide
    for (int i = 0; i < 10; i += 1) {
      expect(find.text('Item $i'), findsOneWidget);
    }

    await tester.pumpWidget(buildFrame(count: 10, width: 160.0));

    // Now the items are 160 pixels wide, so only 5 fit.
    for (int i = 0; i < 5; i += 1) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    for (int i = 5; i < 10; i += 1) {
      expect(find.text('Item $i'), findsNothing);
    }

    await tester.pumpWidget(buildFrame(count: 10, width: 60.0));

    // Now they all fit again
    for (int i = 0; i < 10; i += 1) {
      expect(find.text('Item $i'), findsOneWidget);
    }
  });

  testWidgets('HorizontalListView first item is also the prototype', (WidgetTester tester) async {
    final List<Widget> items = List<Widget>.generate(10, (int index) {
      return TestItem(key: ValueKey<int>(index), item: index, width: index == 0 ? 60.0 : null);
    }).toList();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.custom(
          prototypeItem: items[0],
          childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => items[index],
            childCount: 10,
          ),
        ),
      ),
    );

    // Item 0 exists in the list and as the prototype item.
    expect(tester.widgetList(find.text('Item 0', skipOffstage: false)).length, 2);

    for (int i = 1; i < 10; i += 1) {
      expect(find.text('Item $i'), findsOneWidget);
    }
  });
}