// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexible_horizontal_list_view/src/horizontal_list_view.dart';

import 'rendering_tester.dart' show TestClipPaintingContext;

class Alive extends StatefulWidget {
  const Alive(this.alive, this.index, {super.key});
  final bool alive;
  final int index;

  @override
  AliveState createState() => AliveState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => '$index $alive';
}

class AliveState extends State<Alive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.alive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Text('${widget.index}:$wantKeepAlive');
  }
}

typedef WhetherToKeepAlive = bool Function(int);

class _StatefulListView extends StatefulWidget {
  const _StatefulListView(this.aliveCallback);

  final WhetherToKeepAlive aliveCallback;
  @override
  _StatefulListViewState createState() => _StatefulListViewState();
}

class _StatefulListViewState extends State<_StatefulListView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // force a rebuild - the test(s) using this are verifying that the list is
      // still correct after rebuild
      onTap: () => setState,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          children: List<Widget>.generate(200, (int i) {
            return Builder(
              builder: (BuildContext context) {
                return Alive(widget.aliveCallback(i), i);
              },
            );
          }),
        ),
      ),
    );
  }
}

void main() {
  // Regression test for https://github.com/flutter/flutter/issues/100451
  testWidgets('HorizontalListView.builder respects findChildIndexCallback', (WidgetTester tester) async {
    bool finderCalled = false;
    int itemCount = 7;
    late StateSetter stateSetter;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            stateSetter = setState;
            return HorizontalListView.builder(
              itemCount: itemCount,
              itemBuilder: (BuildContext _, int index) =>
                  Container(key: Key('$index'), width: 2000.0),
              findChildIndexCallback: (Key key) {
                finderCalled = true;
                return null;
              },
            );
          },
        ),
      ),
    );
    expect(finderCalled, false);

    // Trigger update.
    stateSetter(() => itemCount = 77);
    await tester.pump();

    expect(finderCalled, true);
  });

  // Regression test for https://github.com/flutter/flutter/issues/100451
  testWidgets('HorizontalListView.separator respects findChildIndexCallback', (WidgetTester tester) async {
    bool finderCalled = false;
    int itemCount = 7;
    late StateSetter stateSetter;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            stateSetter = setState;
            return HorizontalListView.separated(
              itemCount: itemCount,
              itemBuilder: (BuildContext _, int index) =>
                  Container(key: Key('$index'), width: 2000.0),
              findChildIndexCallback: (Key key) {
                finderCalled = true;
                return null;
              },
              separatorBuilder: (BuildContext _, int __) => const Divider(),
            );
          },
        ),
      ),
    );
    expect(finderCalled, false);

    // Trigger update.
    stateSetter(() => itemCount = 77);
    await tester.pump();

    expect(finderCalled, true);
  });

  testWidgets('HorizontalListView default control', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: HorizontalListView()),
      ),
    );
  });

  testWidgets('HorizontalListView can build out of overflow padding', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox.shrink(
            child: HorizontalListView(
              padding: const EdgeInsets.all(8.0),
              children: const <Widget>[Text('padded', textDirection: TextDirection.ltr)],
            ),
          ),
        ),
      ),
    );
    expect(find.text('padded', skipOffstage: false), findsOneWidget);
  });

  testWidgets('HorizontalListView automatically pad MediaQuery on axis', (WidgetTester tester) async {
    EdgeInsets? innerMediaQueryPadding;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.all(30.0)),
          child: HorizontalListView(
            children: <Widget>[
              const Text('top', textDirection: TextDirection.ltr),
              Builder(
                builder: (BuildContext context) {
                  innerMediaQueryPadding = MediaQuery.paddingOf(context);
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
    // Automatically apply the left/right padding into sliver.
    expect(tester.getTopLeft(find.text('top')).dx, 30.0);
    // Leave top/bottom padding as is for children.
    expect(innerMediaQueryPadding, const EdgeInsets.symmetric(vertical: 30.0));
  });

  testWidgets('HorizontalListView clips if overflow is smaller than cacheExtent', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/17426.

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200.0,
            child: HorizontalListView(
              cacheExtent: 500.0,
              children: <Widget>[
                Container(width: 90.0),
                Container(width: 110.0),
                Container(width: 80.0),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(HorizontalViewport), paints..clipRect());
  });

  testWidgets(
    'HorizontalListView allows touch on children when reaching an edge and over-scrolling / settling',
    (WidgetTester tester) async {
      bool tapped = false;
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      const Duration frame = Duration(milliseconds: 16);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: HorizontalListView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            itemCount: 15,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  tapped = true;
                },
                child: SizedBox(width: 100.0, child: Text('Item $index')),
              );
            },
          ),
        ),
      );

      // Tapping on an item in an idle scrollable should register the tap
      await tester.tap(find.text('Item 0'));
      expect(tapped, isTrue);
      tapped = false;

      await tester.fling(find.byType(HorizontalListView), const Offset(80.0, 0.0), 1000.0);
      // Pump a few frames to ensure the scrollable is in an over-scrolled state
      for (int i = 0; i < 5; i++) {
        await tester.pump(frame);
      }

      expect(controller.offset, lessThan(0.0));

      // Tapping on an item in an over-scrolled state should register the tap
      await tester.tap(find.text('Item 1'));
      expect(tapped, isTrue);
      tapped = false;

      await tester.pumpAndSettle();
      expect(controller.offset, 0.0);

      // Tapping on an item in an idle scrollable should register the tap
      await tester.tap(find.text('Item 2'));
      expect(tapped, isTrue);
      tapped = false;

      // Jump somewhere in the middle of the list
      controller.jumpTo(101.0);
      expect(controller.offset, equals(101.0));

      await tester.tap(find.text('Item 3'));
      expect(tapped, isTrue);
      tapped = false;

      await tester.pumpAndSettle();

      // Strong fling down, to over-scroll the list at the top
      await tester.fling(find.byType(HorizontalListView), const Offset(500.0, 0.0), 5000.0);

      for (int i = 0; i < 5; i++) {
        await tester.pump(frame);
      }

      // Ensure the scrollable is over-scrolled
      expect(controller.offset, lessThan(0.0));

      // Now we are settling, all taps should be registered
      await tester.tap(find.text('Item 2'));
      expect(tapped, isTrue);
      tapped = false;

      await tester.pump(frame);

      await tester.tap(find.text('Item 2'));
      expect(tapped, isTrue);
      tapped = false;

      await tester.pumpAndSettle();

      await tester.tap(find.text('Item 2'));
      expect(tapped, isTrue);
      tapped = false;
    },
  );

  testWidgets('HorizontalListView absorbs touch to stop scrolling when not at the edge', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);

    const Duration frame = Duration(milliseconds: 16);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.builder(
          controller: controller,
          physics: const BouncingScrollPhysics(),
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                tapped = true;
              },
              child: SizedBox(width: 100.0, child: Text('Item $index')),
            );
          },
        ),
      ),
    );

    // Jump somewhere in the middle of the list
    controller.jumpTo(101.0);
    expect(controller.offset, equals(101.0));

    // Tap on an item, it should register the tap
    await tester.tap(find.text('Item 3'));
    expect(tapped, isTrue);
    tapped = false;

    // Fling the list, it should start scrolling. Bot not to the edge
    await tester.fling(find.byType(HorizontalListView), const Offset(100.0, 0.0), 1000.0);

    await tester.pump(frame);

    final double offset = controller.offset;

    // Ensure we are somewhere between 0 and the starting offset
    expect(controller.offset, lessThan(101.0));
    expect(controller.offset, greaterThan(0.0));

    await tester.tap(
      find.text('Item 2'),
      warnIfMissed: false,
    ); // The tap should be absorbed by the HorizontalListView. Therefore warnIfMissed is set to false
    expect(tapped, isFalse);

    // Ensure the scrollable stops in place and doesn't scroll further
    await tester.pump(frame);
    expect(offset, equals(controller.offset));
    await tester.pumpAndSettle();
    expect(offset, equals(controller.offset));

    // Tapping on an item should register the tap normally, as the scrollable is idle
    await tester.tap(find.text('Item 2'));
    expect(tapped, isTrue);
    tapped = false;
  });

  testWidgets('HorizontalListView does not clips if no overflow', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200.0,
            child: HorizontalListView(
              cacheExtent: 500.0,
              children: const <Widget>[
                SizedBox(width: 100.0),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Viewport), isNot(paints..clipRect()));
  });

  testWidgets('HorizontalListView respects clipBehavior', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(children: <Widget>[Container(width: 2000.0)]),
      ),
    );

    // 1st, check that the render object has received the default clip behavior.
    final RenderHorizontalViewport renderObject = tester.allRenderObjects.whereType<RenderHorizontalViewport>().first;
    expect(renderObject.clipBehavior, equals(Clip.hardEdge));

    // 2nd, check that the painting context has received the default clip behavior.
    final TestClipPaintingContext context = TestClipPaintingContext();
    renderObject.paint(context, Offset.zero);
    expect(context.clipBehavior, equals(Clip.hardEdge));

    // 3rd, pump a new widget to check that the render object can update its clip behavior.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView(
          clipBehavior: Clip.antiAlias,
          children: <Widget>[Container(width: 2000.0)],
        ),
      ),
    );
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));

    // 4th, check that a non-default clip behavior can be sent to the painting context.
    renderObject.paint(context, Offset.zero);
    expect(context.clipBehavior, equals(Clip.antiAlias));
    context.dispose();
  });

  testWidgets('HorizontalListView.builder respects clipBehavior', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext _, int __) => Container(width: 2000.0),
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
    final RenderHorizontalViewport renderObject = tester.allRenderObjects.whereType<RenderHorizontalViewport>().first;
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));
  });

  testWidgets('HorizontalListView.custom respects clipBehavior', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.custom(
          childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => Container(width: 2000.0),
            childCount: 1,
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
    final RenderHorizontalViewport renderObject = tester.allRenderObjects.whereType<RenderHorizontalViewport>().first;
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));
  });

  testWidgets('HorizontalListView.separated respects clipBehavior', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.separated(
          itemCount: 10,
          itemBuilder: (BuildContext _, int __) => Container(width: 2000.0),
          separatorBuilder: (BuildContext _, int __) => const Divider(),
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
    final RenderHorizontalViewport renderObject = tester.allRenderObjects.whereType<RenderHorizontalViewport>().first;
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));
  });
}