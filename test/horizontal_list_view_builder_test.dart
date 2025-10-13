// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexible_horizontal_list_view/src/horizontal_list_view.dart';

void main() {
  testWidgets('HorizontalListView.builder 30 items with big jump, using prototypeItem', (
    WidgetTester tester,
  ) async {
    final List<int> callbackTracker = <int>[];

    // The root view is 800x600 in the test environment and our list
    // items are 400 wide. Scrolling should cause two or three items
    // to be built.

    Widget itemBuilder(BuildContext context, int index) {
      callbackTracker.add(index);
      return Text('$index', key: ValueKey<int>(index), textDirection: TextDirection.ltr);
    }

    final Widget testWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: HorizontalListView.builder(
        itemBuilder: itemBuilder,
        prototypeItem: const SizedBox(width: 400, height: 600),
        itemCount: 30,
      ),
    );

    void jumpTo(double newScrollOffset) {
      final ScrollableState scrollable = tester.state(find.byType(Scrollable));
      scrollable.position.jumpTo(newScrollOffset);
    }

    await tester.pumpWidget(testWidget);

    // 2 is in the cache area, but not visible.
    expect(callbackTracker, equals(<int>[0, 1, 2]));
    final List<int> initialExpectedHidden = List<int>.generate(28, (int i) => i + 2);
    check(visible: <int>[0, 1], hidden: initialExpectedHidden);
    callbackTracker.clear();

    // Jump to the end of the HorizontalListView.
    jumpTo(400 * 30 - 400 * 2); // 11_200
    await tester.pump();

    // 27 is in the cache area, but not visible.
    expect(callbackTracker, equals(<int>[27, 28, 29]));
    final List<int> finalExpectedHidden = List<int>.generate(28, (int i) => i);
    check(visible: <int>[28, 29], hidden: finalExpectedHidden);
    callbackTracker.clear();
  });

  testWidgets('HorizontalListView.separated', (WidgetTester tester) async {
    Widget buildFrame({required int itemCount}) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.separated(
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(width: 100.0, child: Text('i$index'));
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 10.0, child: Text('s$index'));
          },
        ),
      );
    }

    await tester.pumpWidget(buildFrame(itemCount: 0));
    expect(find.text('i0'), findsNothing);
    expect(find.text('s0'), findsNothing);

    await tester.pumpWidget(buildFrame(itemCount: 1));
    expect(find.text('i0'), findsOneWidget);
    expect(find.text('s0'), findsNothing);

    await tester.pumpWidget(buildFrame(itemCount: 2));
    expect(find.text('i0'), findsOneWidget);
    expect(find.text('s0'), findsOneWidget);
    expect(find.text('i1'), findsOneWidget);
    expect(find.text('s1'), findsNothing);

    // HorizontalListView's width is 800, so items i0-i7 and s0-s6 fit.
    await tester.pumpWidget(buildFrame(itemCount: 25));
    for (final String s in <String>[
      'i0',
      's0',
      'i1',
      's1',
      'i2',
      's2',
      'i3',
      's3',
      'i4',
      's4',
      'i5',
      's5',
      'i6',
      's6',
      'i7',
    ]) {
      expect(find.text(s), findsOneWidget);
    }
    expect(find.text('s7'), findsNothing);
    expect(find.text('i8'), findsNothing);
  });

  testWidgets('HorizontalListView.separated uses correct semanticChildCount', (WidgetTester tester) async {
    Widget buildFrame({required int itemCount}) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.separated(
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(width: 100.0, child: Text('i$index'));
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 10.0, child: Text('s$index'));
          },
        ),
      );
    }

    Scrollable scrollable() {
      return tester.widget<Scrollable>(
        find.descendant(of: find.byType(HorizontalListView), matching: find.byType(Scrollable)),
      );
    }

    await tester.pumpWidget(buildFrame(itemCount: 0));
    expect(scrollable().semanticChildCount, 0);

    await tester.pumpWidget(buildFrame(itemCount: 1));
    expect(scrollable().semanticChildCount, 1);

    await tester.pumpWidget(buildFrame(itemCount: 2));
    expect(scrollable().semanticChildCount, 2);

    await tester.pumpWidget(buildFrame(itemCount: 3));
    expect(scrollable().semanticChildCount, 3);

    await tester.pumpWidget(buildFrame(itemCount: 4));
    expect(scrollable().semanticChildCount, 4);
  });
}

void check({List<int> visible = const <int>[], List<int> hidden = const <int>[]}) {
  for (final int i in visible) {
    expect(find.text('$i'), findsOneWidget);
  }
  for (final int i in hidden) {
    expect(find.text('$i'), findsNothing);
  }
}