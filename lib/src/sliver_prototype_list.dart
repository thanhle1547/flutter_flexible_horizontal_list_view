import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'unconstrained_sliver_list.dart';

/// A sliver that places its box children in a linear array and constrains them
/// to have the same extent as a prototype item along both the main and
/// cross axis.
///
/// Like [SliverPrototypeExtentList], this widget arranges its children in a line
/// along the main axis starting at offset zero and without gaps.
/// In [SliverPrototypeList], however, each child is constrained to the same
/// extent as the [prototypeItem] along both the main and cross axis.
///
/// [SliverPrototypeList] is more efficient than [UnconstrainedSliverList]
/// because [SliverPrototypeList] does not need to lay out its children to
/// obtain their extent along the main axis.
///
/// See also:
///
///  * [UnconstrainedSliverList], which does not require its children to
///    have the same extent both in the main axis and cross axis.
class SliverPrototypeList extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places its box children in a linear array and
  /// constrains them to have the same extent as a prototype item along
  /// both the main and cross axis.
  const SliverPrototypeList({
    super.key,
    required super.delegate,
    required this.prototypeItem,
  });

  /// Defines the size of all of this sliver's children.
  ///
  /// The [prototypeItem] is laid out before the rest of the sliver's children
  /// and its size fixes the size of each child. The [prototypeItem] is
  /// essentially [Offstage]: it is not painted and it cannot respond to input.
  final Widget prototypeItem;

  @override
  RenderSliverMultiBoxAdaptor createRenderObject(BuildContext context) {
    final _SliverPrototypeListElement element = context as _SliverPrototypeListElement;
    return _RenderSliverPrototypeList(childManager: element);
  }

  @override
  SliverMultiBoxAdaptorElement createElement() => _SliverPrototypeListElement(this);
}

class _SliverPrototypeListElement extends SliverMultiBoxAdaptorElement {
  _SliverPrototypeListElement(SliverPrototypeList super.widget);

  @override
  _RenderSliverPrototypeList get renderObject =>
      super.renderObject as _RenderSliverPrototypeList;

  Element? _prototype;
  static final Object _prototypeSlot = Object();

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant Object slot) {
    if (slot == _prototypeSlot) {
      assert(child is RenderBox);
      renderObject.child = child as RenderBox;
    } else {
      super.insertRenderObjectChild(child, slot as int);
    }
  }

  @override
  void didAdoptChild(RenderBox child) {
    if (child != renderObject.child) {
      super.didAdoptChild(child);
    }
  }

  @override
  void moveRenderObjectChild(RenderBox child, Object oldSlot, Object newSlot) {
    if (newSlot == _prototypeSlot) {
      // There's only one prototype child so it cannot be moved.
      assert(false);
    } else {
      super.moveRenderObjectChild(child, oldSlot as int, newSlot as int);
    }
  }

  @override
  void removeRenderObjectChild(RenderBox child, Object slot) {
    if (renderObject.child == child) {
      renderObject.child = null;
    } else {
      super.removeRenderObjectChild(child, slot as int);
    }
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_prototype != null) {
      visitor(_prototype!);
    }
    super.visitChildren(visitor);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _prototype = updateChild(
      _prototype,
      (widget as SliverPrototypeList).prototypeItem,
      _prototypeSlot,
    );
  }

  @override
  void update(SliverPrototypeList newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _prototype = updateChild(
      _prototype,
      (widget as SliverPrototypeList).prototypeItem,
      _prototypeSlot,
    );
  }
}

class _RenderSliverPrototypeList extends RenderSliverMultiBoxAdaptor {
  _RenderSliverPrototypeList({required _SliverPrototypeListElement childManager})
    : super(childManager: childManager);

  RenderBox? _child;
  RenderBox? get child => _child;
  set child(RenderBox? value) {
    if (_child != null) {
      dropChild(_child!);
    }
    _child = value;
    if (_child != null) {
      adoptChild(_child!);
    }
    markNeedsLayout();
  }

  double get itemExtent {
    assert(child != null && child!.hasSize);
    return constraints.axis == Axis.vertical ? child!.size.height : child!.size.width;
  }

  /// The layout offset for the child with the given index.
  ///
  /// By default, places the children in order, without gaps, starting from
  /// layout offset zero.
  @visibleForTesting
  @protected
  double indexToLayoutOffset(int index) {
    return itemExtent * index;
  }

  /// The minimum child index that is visible at the given scroll offset.
  ///
  /// By default, returns a value consistent with the children being placed in
  /// order, without gaps, starting from layout offset zero.
  @visibleForTesting
  @protected
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final double itemExtent = this.itemExtent;
    if (itemExtent > 0.0) {
      final double actual = scrollOffset / itemExtent;
      final int round = actual.round();
      if ((actual * itemExtent - round * itemExtent).abs() < precisionErrorTolerance) {
        return round;
      }
      return actual.floor();
    }
    return 0;
  }

  /// The maximum child index that is visible at the given scroll offset.
  ///
  /// By default, returns a value consistent with the children being placed in
  /// order, without gaps, starting from layout offset zero.
  @visibleForTesting
  @protected
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final double itemExtent = this.itemExtent;
    if (itemExtent > 0.0) {
      final double actual = scrollOffset / itemExtent - 1;
      final int round = actual.round();
      if ((actual * itemExtent - round * itemExtent).abs() < precisionErrorTolerance) {
        return math.max(0, round);
      }
      return math.max(0, actual.ceil());
    }
    return 0;
  }

  /// Called to estimate the total scrollable extents of this object.
  ///
  /// Must return the total distance from the start of the child with the
  /// earliest possible index to the end of the child with the last possible
  /// index.
  ///
  /// By default, defers to [RenderSliverBoxChildManager.estimateMaxScrollOffset].
  ///
  /// See also:
  ///
  ///  * [computeMaxScrollOffset], which is similar but must provide a precise
  ///    value.
  @protected
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  }) {
    return childManager.estimateMaxScrollOffset(
      constraints,
      firstIndex: firstIndex,
      lastIndex: lastIndex,
      leadingScrollOffset: leadingScrollOffset,
      trailingScrollOffset: trailingScrollOffset,
    );
  }

  /// Called to obtain a precise measure of the total scrollable extents of this
  /// object.
  ///
  /// Must return the precise total distance from the start of the child with
  /// the earliest possible index to the end of the child with the last possible
  /// index.
  ///
  /// This is used when no child is available for the index corresponding to the
  /// current scroll offset, to determine the precise dimensions of the sliver.
  /// It must return a precise value. It will not be called if the
  /// [childManager] returns an infinite number of children for positive
  /// indices.
  ///
  /// If [itemExtentBuilder] is null, multiplies the [itemExtent] by the number
  /// of children reported by [RenderSliverBoxChildManager.childCount].
  /// If [itemExtentBuilder] is non-null, sum the extents of the first
  /// [RenderSliverBoxChildManager.childCount] children.
  ///
  /// See also:
  ///
  ///  * [estimateMaxScrollOffset], which is similar but may provide inaccurate
  ///    values.
  @visibleForTesting
  @protected
  double computeMaxScrollOffset(SliverConstraints constraints) {
    return childManager.childCount * itemExtent;
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;

    final BoxConstraints prototypeChildConstraints = constraints.axis == Axis.horizontal
        ? BoxConstraints(
            minHeight: 0.0,
            maxHeight: constraints.crossAxisExtent,
            minWidth: 0.0,
            maxWidth: double.infinity,
          )
        : BoxConstraints(
            minHeight: 0.0,
            maxHeight: double.infinity,
            minWidth: 0.0,
            maxWidth: constraints.crossAxisExtent,
          );
    child!.layout(prototypeChildConstraints, parentUsesSize: true);

    final BoxConstraints childConstraints = BoxConstraints.tight(child!.size);

    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset = constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    final int firstIndex = getMinChildIndexForScrollOffset(scrollOffset);
    final int? targetLastIndex =
        targetEndScrollOffset.isFinite
            ? getMaxChildIndexForScrollOffset(targetEndScrollOffset)
            : null;

    if (firstChild != null) {
      final int leadingGarbage = calculateLeadingGarbage(firstIndex: firstIndex);
      final int trailingGarbage =
          targetLastIndex != null ? calculateTrailingGarbage(lastIndex: targetLastIndex) : 0;
      collectGarbage(leadingGarbage, trailingGarbage);
    } else {
      collectGarbage(0, 0);
    }

    if (firstChild == null) {
      final double layoutOffset = indexToLayoutOffset(firstIndex);
      if (!addInitialChild(index: firstIndex, layoutOffset: layoutOffset)) {
        // There are either no children, or we are past the end of all our children.
        final double max;
        if (firstIndex <= 0) {
          max = 0.0;
        } else {
          max = computeMaxScrollOffset(constraints);
        }
        geometry = SliverGeometry(scrollExtent: max, maxPaintExtent: max);
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox? trailingChildWithLayout;

    for (int index = indexOf(firstChild!) - 1; index >= firstIndex; --index) {
      final RenderBox? child = insertAndLayoutLeadingChild(childConstraints);
      if (child == null) {
        // Items before the previously first child are no longer present.
        // Reset the scroll offset to offset all items prior and up to the
        // missing item. Let parent re-layout everything.
        geometry = SliverGeometry(
          scrollOffsetCorrection: indexToLayoutOffset(index),
        );
        return;
      }
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData! as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(index);
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
    }

    if (trailingChildWithLayout == null) {
      firstChild!.layout(childConstraints);
      final SliverMultiBoxAdaptorParentData childParentData =
          firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(firstIndex);
      trailingChildWithLayout = firstChild;
    }

    double estimatedMaxScrollOffset = double.infinity;
    for (
      int index = indexOf(trailingChildWithLayout!) + 1;
      targetLastIndex == null || index <= targetLastIndex;
      ++index
    ) {
      RenderBox? child = childAfter(trailingChildWithLayout!);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(childConstraints, after: trailingChildWithLayout);
        if (child == null) {
          // We have run out of children.
          estimatedMaxScrollOffset = indexToLayoutOffset(index);
          break;
        }
      } else {
        child.layout(childConstraints);
      }
      trailingChildWithLayout = child;
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData! as SliverMultiBoxAdaptorParentData;
      assert(childParentData.index == index);
      childParentData.layoutOffset = indexToLayoutOffset(
        childParentData.index!,
      );
    }

    final int lastIndex = indexOf(lastChild!);
    final double leadingScrollOffset = indexToLayoutOffset(firstIndex);
    final double trailingScrollOffset = indexToLayoutOffset(
      lastIndex + 1,
    );

    assert(
      firstIndex == 0 || childScrollOffset(firstChild!)! - scrollOffset <= precisionErrorTolerance,
    );
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild!) == firstIndex);
    assert(targetLastIndex == null || lastIndex <= targetLastIndex);

    estimatedMaxScrollOffset = math.min(
      estimatedMaxScrollOffset,
      estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      ),
    );

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    final int? targetLastIndexForPaint =
        targetEndScrollOffsetForPaint.isFinite
            ? getMaxChildIndexForScrollOffset(
              targetEndScrollOffsetForPaint,
            )
            : null;

    double crossAxisExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        crossAxisExtent = child!.size.height;
      case Axis.vertical:
        crossAxisExtent = child!.size.width;
    }

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      crossAxisExtent: crossAxisExtent,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow:
          (targetLastIndexForPaint != null && lastIndex >= targetLastIndexForPaint) ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == trailingScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _child?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _child?.detach();
  }

  @override
  void redepthChildren() {
    if (_child != null) {
      redepthChild(_child!);
    }
    super.redepthChildren();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_child != null) {
      visitor(_child!);
    }
    super.visitChildren(visitor);
  }
}
