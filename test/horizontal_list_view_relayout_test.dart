// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexible_horizontal_list_view/flexible_horizontal_list_view.dart';
import 'package:flexible_horizontal_list_view/src/unconstrained_sliver_list.dart';

void main() {
  testWidgets('Underflowing HorizontalListView should relayout for additional children', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/5950

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(children: const <Widget>[SizedBox(width: 100.0, child: Text('100'))]),
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          children: const <Widget>[
            SizedBox(width: 100.0, child: Text('100')),
            SizedBox(width: 200.0, child: Text('200')),
          ],
        ),
      ),
    );

    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('Underflowing HorizontalListView contentExtent should track additional children', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(children: const <Widget>[SizedBox(width: 100.0, child: Text('100'))]),
      ),
    );

    final RenderUnconstrainedSliverList list = tester.renderObject(find.byType(UnconstrainedSliverList));
    expect(list.geometry!.scrollExtent, equals(100.0));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          children: const <Widget>[
            SizedBox(width: 100.0, child: Text('100')),
            SizedBox(width: 200.0, child: Text('200')),
          ],
        ),
      ),
    );
    expect(list.geometry!.scrollExtent, equals(300.0));

    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: HorizontalListView()));
    expect(list.geometry!.scrollExtent, equals(0.0));
  });

  testWidgets('Overflowing HorizontalListView should relayout for missing children', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          children: const <Widget>[
            SizedBox(width: 300.0, child: Text('300')),
            SizedBox(width: 400.0, child: Text('400')),
          ],
        ),
      ),
    );

    expect(find.text('300'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(children: const <Widget>[SizedBox(width: 300.0, child: Text('300'))]),
      ),
    );

    expect(find.text('300'), findsOneWidget);
    expect(find.text('400'), findsNothing);

    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: HorizontalListView()));

    expect(find.text('300'), findsNothing);
    expect(find.text('400'), findsNothing);
  });

  testWidgets('Overflowing HorizontalListView should not relayout for additional children', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          children: const <Widget>[
            SizedBox(width: 400.0, child: Text('400')),
            SizedBox(width: 500.0, child: Text('500')),
          ],
        ),
      ),
    );

    expect(find.text('400'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          children: const <Widget>[
            SizedBox(width: 400.0, child: Text('400')),
            SizedBox(width: 500.0, child: Text('500')),
            SizedBox(width: 100.0, child: Text('100')),
          ],
        ),
      ),
    );

    expect(find.text('400'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('100'), findsNothing);
  });

  testWidgets('Overflowing HorizontalListView should become scrollable', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/5920
    // When a HorizontalListView's viewport hasn't overflowed, scrolling is disabled.
    // When children are added that cause it to overflow, scrolling should be enabled.

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(children: const <Widget>[SizedBox(width: 100.0, child: Text('100'))]),
      ),
    );

    final ScrollableState scrollable = tester.state(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, 0.0);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          children: const <Widget>[
            SizedBox(width: 100.0, child: Text('100')),
            SizedBox(width: 400.0, child: Text('400')),
            SizedBox(width: 400.0, child: Text('400')),
          ],
        ),
      ),
    );

    expect(scrollable.position.maxScrollExtent, 100.0);
  });
}