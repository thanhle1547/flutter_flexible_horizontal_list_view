// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexible_horizontal_list_view/src/horizontal_list_view.dart';

const double kWidth = 10.0;
const double kFlingOffset = kWidth * 20.0;

void main() {
  testWidgets("Flings don't stutter", (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HorizontalListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Container(width: kWidth);
          },
        ),
      ),
    );

    double getCurrentOffset() {
      return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
    }

    await tester.fling(find.byType(HorizontalListView), const Offset(-kFlingOffset, 0.0), 1000.0);
    expect(getCurrentOffset(), kFlingOffset);
    await tester.pump(); // process the up event
    while (tester.binding.transientCallbackCount > 0) {
      final double lastOffset = getCurrentOffset();
      await tester.pump(const Duration(milliseconds: 20));
      expect(getCurrentOffset(), greaterThan(lastOffset));
    }
  });
}