import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'sliver_prototype_list.dart';
import 'unconstrained_sliver_list.dart';

/// A direction along the horizontal [Axis] in which the origin,
/// or zero position, is determined.
///
/// This value relates to the direction in which the scroll offset increases
/// from the origin. This value does not represent the direction of user input
/// that may be modifying the scroll offset, such as from a drag. For the
/// active scrolling direction, see [ScrollDirection].
///
/// See also:
///
///   * [ScrollDirection], the direction of active scrolling, relative to the positive
///     scroll offset axis given by an [AxisDirection] and a [GrowthDirection].
///   * [GrowthDirection], the direction in which slivers and their content are
///     ordered, relative to the scroll offset axis as specified by
///     [AxisDirection].
enum HorizontalAxisDirection {
  /// A direction in the [Axis.horizontal] where zero is on the left and
  /// positive values are to the right of it: `⇉`
  ///
  /// Alphabetical content with a [GrowthDirection.forward] would have the A on
  /// the left and the Z on the right. This is the ordinary reading order for a
  /// horizontal set of tabs in an English application, for example.
  right,

  /// A direction in the [Axis.horizontal] where zero is to the right and
  /// positive values are to the left of it: `⇇`
  ///
  /// Alphabetical content with a [GrowthDirection.forward] would have the A at
  /// the right and the Z at the left. This is the ordinary reading order for a
  /// horizontal set of tabs in a Hebrew application, for example.
  left,
}

/// Returns the [HorizontalAxisDirection] in which reading occurs
/// in the given [TextDirection].
///
/// Specifically, returns [HorizontalAxisDirection.left] for [TextDirection.rtl] and
/// [HorizontalAxisDirection.right] for [TextDirection.ltr].
HorizontalAxisDirection textDirectionToAxisDirection(TextDirection textDirection) {
  return switch (textDirection) {
    TextDirection.rtl => HorizontalAxisDirection.left,
    TextDirection.ltr => HorizontalAxisDirection.right,
  };
}

/// Returns the opposite of the given [HorizontalAxisDirection].
///
/// Specifically, [HorizontalAxisDirection.left] for
/// [HorizontalAxisDirection.right] (and vice versa).
HorizontalAxisDirection flipAxisDirection(HorizontalAxisDirection axisDirection) {
  return switch (axisDirection) {
    HorizontalAxisDirection.right => HorizontalAxisDirection.left,
    HorizontalAxisDirection.left => HorizontalAxisDirection.right,
  };
}

/// Returns the [AxisDirection] in which reading occurs
/// in the given [HorizontalAxisDirection].
///
/// Specifically, returns [HorizontalAxisDirection.left] for [AxisDirection.left]
/// and [HorizontalAxisDirection.right] for [AxisDirection.right].
AxisDirection horizontalAxisDirectionToAxisDirection(HorizontalAxisDirection axisDirection) {
  return switch (axisDirection) {
    HorizontalAxisDirection.left => AxisDirection.left,
    HorizontalAxisDirection.right => AxisDirection.right,
  };
}

/// Flips the [HorizontalAxisDirection] if the [GrowthDirection]
/// is [GrowthDirection.reverse].
///
/// This function is useful in [RenderSliver] subclasses that are given both an
/// [AxisDirection] and a [GrowthDirection] and wish to compute the
/// [AxisDirection] in which growth will occur.
HorizontalAxisDirection applyGrowthDirectionToAxisDirection(
  AxisDirection axisDirection,
  GrowthDirection growthDirection,
) {
  final HorizontalAxisDirection horizontalAxisDirection = switch (axisDirection) {
    AxisDirection.left => HorizontalAxisDirection.left,
    AxisDirection.right => HorizontalAxisDirection.right,
    _ => throw UnimplementedError(),
  };

  return applyGrowthDirectionToHorizontalAxisDirection(horizontalAxisDirection, growthDirection);
}

/// Flips the [HorizontalAxisDirection] if the [GrowthDirection]
/// is [GrowthDirection.reverse].
///
/// Specifically, returns `axisDirection` if `growthDirection` is
/// [GrowthDirection.forward], otherwise returns [flipAxisDirection] applied to
/// `axisDirection`.
///
/// This function is useful in [RenderSliver] subclasses that are given both an
/// [AxisDirection] and a [GrowthDirection] and wish to compute the
/// [AxisDirection] in which growth will occur.
HorizontalAxisDirection applyGrowthDirectionToHorizontalAxisDirection(
  HorizontalAxisDirection axisDirection,
  GrowthDirection growthDirection,
) {
  return switch (growthDirection) {
    GrowthDirection.forward => axisDirection,
    GrowthDirection.reverse => flipAxisDirection(axisDirection),
  };
}

/// A widget that combines a [Scrollable] and a [HorizontalViewport] to create
/// an interactive scrolling pane of content in one dimension.
///
/// [HorizontalScrollView] helps orchestrate these pieces by creating
/// the [Scrollable] and the viewport and deferring to its subclass to
/// create the slivers.
///
/// To control the initial scroll offset of the scroll view, provide a
/// [controller] with its [ScrollController.initialScrollOffset] property set.
///
/// {@macro flutter.widgets.ScrollView.PageStorage}
///
/// See also:
///
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
abstract class HorizontalScrollView extends StatelessWidget {
  /// Creates a widget that scrolls.
  const HorizontalScrollView({
    super.key,
    this.reverse = false,
    this.controller,
    this.physics,
    this.scrollBehavior,
    this.flexibleHeight = false,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
  }) : assert(semanticChildCount == null || semanticChildCount >= 0);

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// If the reading direction is left-to-right, then the scroll view
  /// scrolls from left to right when [reverse] is false and from right to left
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.scroll_view.physics}
  ///
  /// If an explicit [ScrollBehavior] is provided to [scrollBehavior], the
  /// [ScrollPhysics] provided by that behavior will take precedence after
  /// [physics].
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.scrollBehavior}
  final ScrollBehavior? scrollBehavior;

  /// Whether the height of the viewport should be determined by
  /// the currently being viewed or by all the laid out children.
  ///
  /// When true, the viewport's height shrinks to fit
  /// to match the height of the currently visible laid out child.
  /// The overall height will change dynamically as the user scrolls.
  ///
  /// When false (default), the [HorizontalScrollView] sizes itself
  /// to match the tallest currently laid out child.
  final bool flexibleHeight;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// The number of children that will contribute semantic information.
  ///
  /// Some subtypes of [HorizontalScrollView] can infer this value automatically. For
  /// example [HorizontalListView] will use the number of widgets in the child list,
  /// while the [HorizontalListView.separated] constructor will use half that amount.
  ///
  /// For [CustomScrollView] and other types which do not receive a builder
  /// or list of widgets, the child count must be explicitly provided. If the
  /// number is unknown or unbounded this should be left unset or set to null.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.scrollChildCount], the corresponding semantics property.
  final int? semanticChildCount;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.widgets.scrollable.hitTestBehavior}
  ///
  /// Defaults to [HitTestBehavior.opaque].
  final HitTestBehavior hitTestBehavior;

  /// Returns the [HorizontalAxisDirection] in which the scroll view scrolls.
  ///
  /// Combines the [Axis.horizontal] with the [reverse] boolean to obtain the
  /// concrete [HorizontalAxisDirection].
  ///
  /// The ambient [Directionality] is considered when selecting the concrete
  /// [HorizontalAxisDirection]. For example, if the ambient [Directionality] is
  /// [TextDirection.rtl], then the non-reversed [HorizontalAxisDirection] is
  /// [HorizontalAxisDirection.left] and the reversed [HorizontalAxisDirection] is
  /// [HorizontalAxisDirection.right].
  @protected
  HorizontalAxisDirection getDirection(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final TextDirection textDirection = Directionality.of(context);
    final HorizontalAxisDirection axisDirection = textDirectionToAxisDirection(textDirection);
    return reverse ? flipAxisDirection(axisDirection) : axisDirection;
  }

  /// Build the list of widgets to place inside the viewport.
  ///
  /// Subclasses should override this method to build the slivers for the inside
  /// of the viewport.
  ///
  /// To learn more about slivers, see [CustomScrollView.slivers].
  @protected
  List<Widget> buildSlivers(BuildContext context);

  /// Build the viewport.
  ///
  /// The `offset` argument is the value obtained from
  /// [Scrollable.viewportBuilder].
  ///
  /// The `slivers` argument is the value obtained from [buildSlivers].
  @protected
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    HorizontalAxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    return HorizontalViewport(
      axisDirection: axisDirection,
      offset: offset,
      slivers: slivers,
      flexibleHeight: flexibleHeight,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = buildSlivers(context);
    final HorizontalAxisDirection horizontalAxisDirection = getDirection(context);
    final AxisDirection axisDirection = horizontalAxisDirectionToAxisDirection(horizontalAxisDirection);

    final Scrollable scrollable = Scrollable(
      dragStartBehavior: dragStartBehavior,
      axisDirection: axisDirection,
      controller: controller,
      physics: physics,
      scrollBehavior: scrollBehavior,
      semanticChildCount: semanticChildCount,
      restorationId: restorationId,
      hitTestBehavior: hitTestBehavior,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return buildViewport(context, offset, horizontalAxisDirection, slivers);
      },
      clipBehavior: clipBehavior,
    );

    final Widget scrollableResult = scrollable;

    if (keyboardDismissBehavior == ScrollViewKeyboardDismissBehavior.onDrag) {
      return NotificationListener<ScrollUpdateNotification>(
        child: scrollableResult,
        onNotification: (ScrollUpdateNotification notification) {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (notification.dragDetails != null &&
              !currentScope.hasPrimaryFocus &&
              currentScope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          return false;
        },
      );
    } else {
      return scrollableResult;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('reverse', value: reverse, ifTrue: 'reversed', showName: true));
    properties.add(
      DiagnosticsProperty<ScrollController>(
        'controller',
        controller,
        showName: false,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<ScrollPhysics>('physics', physics, showName: false, defaultValue: null),
    );
  }
}

/// A [CustomHorizontalScrollView] that creates custom scroll effects
/// using [slivers].
///
/// A [CustomHorizontalScrollView] lets you supply [slivers] directly to create
/// .
///
/// [Widget]s in these [slivers] must produce [RenderSliver] objects.
///
/// To control the initial scroll offset of the scroll view, provide a
/// [controller] with its [ScrollController.initialScrollOffset] property set.
///
/// ## Accessibility
///
/// A [CustomHorizontalScrollView] can allow Talkback/VoiceOver to make
/// announcements to the user when the scroll state changes. For example,
/// on Android an announcement might be read as "showing items 1 to 10 of 23".
/// To produce this announcement, the scroll view needs three pieces of
/// information:
///
///   * The first visible child index.
///   * The total number of children.
///   * The total number of visible children.
///
/// The last value can be computed exactly by the framework, however the first
/// two must be provided. Most of the higher-level scrollable widgets provide
/// this information automatically. For example, [HorizontalListView] provides
/// each child widget with a semantic index automatically and sets
/// the semantic child count to the length of the list.
///
/// To determine visible indexes, the scroll view needs a way to associate the
/// generated semantics of each scrollable item with a semantic index. This can
/// be done by wrapping the child widgets in an [IndexedSemantics].
///
/// This semantic index is not necessarily the same as the index of the widget in
/// the scrollable, because some widgets may not contribute semantic
/// information. Consider a [HorizontalListView.separated]: every other widget
/// is a divider with no semantic information. In this case, only odd numbered
/// widgets have a semantic index (equal to the index ~/ 2). Furthermore, the
/// total number of children in this example would be half the number of
/// widgets. (The [HorizontalListView.separated] constructor handles this
/// automatically; this is only used here as an example.)
///
/// The total number of visible children can be provided by the constructor
/// parameter `semanticChildCount`. This should always be the same as the
/// number of widgets wrapped in [IndexedSemantics].
///
/// {@macro flutter.widgets.ScrollView.PageStorage}
///
/// See also:
///
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
///  * [IndexedSemantics], which allows annotating child lists with an index
///    for scroll announcements.
class CustomHorizontalScrollView extends HorizontalScrollView {
  /// Creates a [CustomHorizontalScrollView] that creates custom scroll effects
  /// using slivers.
  ///
  /// See the [CustomHorizontalScrollView] constructor for more details on
  /// these arguments.
  const CustomHorizontalScrollView({
    super.key,
    super.reverse,
    super.controller,
    super.physics,
    super.scrollBehavior,
    super.cacheExtent,
    this.slivers = const <Widget>[],
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
  });

  /// The slivers to place inside the viewport.
  ///
  /// ## What is a sliver?
  ///
  /// > _**sliver** (noun): a small, thin piece of something._
  ///
  /// A _sliver_ is a widget backed by a [RenderSliver] subclass, i.e. one that
  /// implements the constraint/geometry protocol that uses [SliverConstraints]
  /// and [SliverGeometry].
  ///
  /// This is as distinct from those widgets that are backed by [RenderBox]
  /// subclasses, which use [BoxConstraints] and [Size] respectively, and are
  /// known as box widgets. (Widgets like [Container], [Row], and [SizedBox] are
  /// box widgets.)
  ///
  /// While boxes are much more straightforward (implementing a simple
  /// two-dimensional Cartesian layout system), slivers are much more powerful,
  /// and are optimized for one-axis scrolling environments.
  ///
  /// Slivers are hosted in viewports, also known as scroll views, most notably
  /// [CustomScrollView].
  ///
  /// ## Benefits of slivers over boxes
  ///
  /// The sliver protocol ([SliverConstraints] and [SliverGeometry]) enables
  /// _scroll effects_, such as floating app bars, widgets that expand and
  /// shrink during scroll, section headers that are pinned only while the
  /// section's children are visible, etc.
  ///
  /// {@youtube 560 315 https://www.youtube.com/watch?v=Mz3kHQxBjGg}
  ///
  /// ## Performance considerations
  ///
  /// Because the purpose of scroll views is to, well, scroll, it is common
  /// for scroll views to contain more contents than are rendered on the screen
  /// at any particular time.
  ///
  /// To improve the performance of scroll views, the content can be rendered in
  /// _lazy_ widgets, notably [SliverList] and [SliverGrid] (and their variants,
  /// such as [SliverFixedExtentList] and [SliverAnimatedGrid]). These widgets
  /// ensure that only the portion of their child lists that are actually
  /// visible get built, laid out, and painted.
  ///
  /// The [HorizontalListView] widget provide a convenient way to combine
  /// a [CustomHorizontalScrollView] and a [UnconstrainedSliverList] or
  /// [SliverPrototypeListrid] (respectively).
  final List<Widget> slivers;

  @override
  List<Widget> buildSlivers(BuildContext context) => slivers;
}

/// A widget through which a portion of larger content can be viewed, typically
/// in combination with a [Scrollable].
///
/// [HorizontalViewport] is the visual workhorse of the scrolling machinery.
/// It displays a subset of its children according to its own dimensions and
/// the given [offset]. As the offset varies, different children are visible
/// through the viewport.
///
/// [HorizontalViewport] cannot contain box children directly. Instead, use a
/// [UnconstrainedSliverList], [SliverPrototypeList] or a [SliverToBoxAdapter],
/// for example.
///
/// See also:
///
///  * [SliverToBoxAdapter], which allows a box widget to be placed inside a
///    sliver context (the opposite of this widget).
///  * [ViewportElementMixin], which should be mixed in to the [Element] type used
///    by viewport-like widgets to correctly handle scroll notifications.
class HorizontalViewport extends MultiChildRenderObjectWidget {
  /// Creates a widget that is bigger on the inside.
  ///
  /// The viewport listens to the [offset], which means you do not need to
  /// rebuild this widget when the [offset] changes.
  ///
  /// The [cacheExtent] must be specified if the [cacheExtentStyle] is
  /// not [CacheExtentStyle.pixel].
  const HorizontalViewport({
    super.key,
    this.axisDirection = HorizontalAxisDirection.right,
    required this.offset,
    this.flexibleHeight = false,
    this.cacheExtent,
    this.cacheExtentStyle = CacheExtentStyle.pixel,
    this.clipBehavior = Clip.hardEdge,
    List<Widget> slivers = const <Widget>[],
  }) : assert(cacheExtentStyle != CacheExtentStyle.viewport || cacheExtent != null),
       super(children: slivers);

  /// The direction in which the [offset]'s [ViewportOffset.pixels] increases.
  ///
  /// For example, if the [axisDirection] is [HorizontalAxisDirection.right],
  /// a scroll offset of zero is at the left of the viewport and
  /// increases towards the right of the viewport.
  final HorizontalAxisDirection axisDirection;

  /// Which part of the content inside the viewport should be visible.
  ///
  /// The [ViewportOffset.pixels] value determines the scroll offset that the
  /// viewport uses to select which part of its content to display. As the user
  /// scrolls the viewport, this value changes, which changes the content that
  /// is displayed.
  ///
  /// Typically a [ScrollPosition].
  final ViewportOffset offset;

  /// Whether the height of the viewport should be determined by
  /// the currently being viewed or by all the laid out children.
  ///
  /// When true, the viewport's height shrinks to fit
  /// to match the height of the currently visible laid out child.
  /// The overall height will change dynamically as the user scrolls.
  ///
  /// When false (default), the [RenderHorizontalViewport] sizes itself
  /// to match the tallest currently laid out child.
  final bool flexibleHeight;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  ///
  /// See also:
  ///
  ///  * [cacheExtentStyle], which controls the units of the [cacheExtent].
  final double? cacheExtent;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtentStyle}
  final CacheExtentStyle cacheExtentStyle;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  RenderHorizontalViewport createRenderObject(BuildContext context) {
    return RenderHorizontalViewport(
      axisDirection: axisDirection,
      offset: offset,
      flexibleHeight: flexibleHeight,
      cacheExtent: cacheExtent,
      cacheExtentStyle: cacheExtentStyle,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHorizontalViewport renderObject) {
    renderObject
      ..axisDirection = axisDirection
      ..offset = offset
      ..flexibleHeight = flexibleHeight
      ..cacheExtent = cacheExtent
      ..cacheExtentStyle = cacheExtentStyle
      ..clipBehavior = clipBehavior;
  }

  @override
  MultiChildRenderObjectElement createElement() => _ViewportElement(this);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HorizontalAxisDirection>('axisDirection', axisDirection));
    properties.add(DiagnosticsProperty<ViewportOffset>('offset', offset));
    properties.add(DiagnosticsProperty<double>('cacheExtent', cacheExtent));
    properties.add(DiagnosticsProperty<CacheExtentStyle>('cacheExtentStyle', cacheExtentStyle));
  }
}

class _ViewportElement extends MultiChildRenderObjectElement
    with NotifiableElementMixin, ViewportElementMixin {
  /// Creates an element that uses the given widget as its configuration.
  _ViewportElement(HorizontalViewport super.widget);

  @override
  RenderHorizontalViewport get renderObject => super.renderObject as RenderHorizontalViewport;

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    children
        .where((Element e) {
          final RenderSliver renderSliver = e.renderObject! as RenderSliver;
          return renderSliver.geometry!.visible;
        })
        .forEach(visitor);
  }
}

/// A render object that is bigger on the inside.
///
/// [RenderHorizontalViewport] is the visual workhorse of
/// the scrolling machinery. It displays a subset of its children
/// according to its own dimensions and the given [offset].
/// As the offset varies, different children are visible through the viewport.
///
/// [RenderHorizontalViewport] cannot contain [RenderBox] children directly.
/// Instead, use a [RenderUnconstrainedSliverList], [RenderSliverFixedExtentList],
/// for example.
///
/// See also:
///
///  * [RenderSliver], which explains more about the Sliver protocol.
///  * [RenderBox], which explains more about the Box protocol.
///  * [RenderUnconstrainedSliverToBoxAdapter], which allows a [RenderBox] object to be
///    placed inside a [RenderSliver] (the opposite of this class).
///  * [RenderViewport], a viewport that does not shrink-wrap its contents.
///  * [RenderShrinkWrappingViewport], a variant of [RenderViewport] that
///    shrink-wraps its contents along the main axis.
class RenderHorizontalViewport extends RenderBox
    with ContainerRenderObjectMixin<RenderSliver, SliverPhysicalContainerParentData>
    implements RenderAbstractViewport {
  /// Creates a viewport for [RenderSliver] objects.
  ///
  /// The [offset] must be specified. For testing purposes, consider passing a
  /// [ViewportOffset.zero] or [ViewportOffset.fixed].
  RenderHorizontalViewport({
    HorizontalAxisDirection axisDirection = HorizontalAxisDirection.right,
    required ViewportOffset offset,
    List<RenderSliver>? children,
    bool flexibleHeight = false,
    double? cacheExtent,
    CacheExtentStyle cacheExtentStyle = CacheExtentStyle.pixel,
    Clip clipBehavior = Clip.hardEdge,
  }) : assert(cacheExtentStyle != CacheExtentStyle.viewport || cacheExtent != null),
       assert(cacheExtent != null || cacheExtentStyle == CacheExtentStyle.pixel),
       _axisDirection = axisDirection,
       _offset = offset,
       _flexibleHeight = flexibleHeight,
       _cacheExtent = cacheExtent ?? RenderAbstractViewport.defaultCacheExtent,
       _cacheExtentStyle = cacheExtentStyle,
       _clipBehavior = clipBehavior {
    addAll(children);
  }

  /// Report the semantics of this node, for example for accessibility purposes.
  ///
  /// [RenderHorizontalViewport] adds [RenderViewport.useTwoPaneSemantics] to
  /// the provided [SemanticsConfiguration] to support children using
  /// [RenderViewport.excludeFromScrolling].
  ///
  /// This method should be overridden by subclasses that have interesting
  /// semantic information. Overriding subclasses should call
  /// `super.describeSemanticsConfiguration(config)` to ensure
  /// [RenderViewport.useTwoPaneSemantics] is still added to `config`.
  ///
  /// See also:
  ///
  /// * [RenderObject.describeSemanticsConfiguration], for important
  ///   details about not mutating a [SemanticsConfiguration] out of context.
  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config.addTagForChildren(RenderViewport.useTwoPaneSemantics);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    childrenInPaintOrder
        .where(
          (RenderSliver sliver) =>
              sliver.geometry!.visible ||
              sliver.geometry!.cacheExtent > 0.0,
        )
        .forEach(visitor);
  }

  /// The direction in which the [SliverConstraints.scrollOffset] increases.
  ///
  /// For example, if the [axisDirection] is [HorizontalAxisDirection.right],
  /// a scroll offset of zero is at the left of the viewport and
  /// increases towards the right of the viewport.
  HorizontalAxisDirection get axisDirection => _axisDirection;
  HorizontalAxisDirection _axisDirection;
  set axisDirection(HorizontalAxisDirection value) {
    if (value == _axisDirection) {
      return;
    }
    _axisDirection = value;
    markNeedsLayout();
  }

  /// Which part of the content inside the viewport should be visible.
  ///
  /// The [ViewportOffset.pixels] value determines the scroll offset that the
  /// viewport uses to select which part of its content to display. As the user
  /// scrolls the viewport, this value changes, which changes the content that
  /// is displayed.
  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    if (value == _offset) {
      return;
    }
    if (attached) {
      _offset.removeListener(markNeedsLayout);
    }
    _offset = value;
    if (attached) {
      _offset.addListener(markNeedsLayout);
    }
    // We need to go through layout even if the new offset has the same pixels
    // value as the old offset so that we will apply our viewport and content
    // dimensions.
    markNeedsLayout();
  }

  /// Whether the cross axis extent of the viewport should be
  /// determined by the currently being viewed or by all the laid out children.
  ///
  /// When true, the viewport's cros -axis extent shrinks to fit
  /// the maximum cross axis size of the children currently visible.
  /// The overall cross axis size will change dynamically as the user scrolls.
  ///
  /// When false (default), the [RenderHorizontalViewport] sizes itself
  /// to match the maximum cross axis extent of all children
  /// that have been laid out.
  bool get flexibleHeight => _flexibleHeight;
  bool _flexibleHeight;
  set flexibleHeight(bool value) {
    if (value == _flexibleHeight) {
      return;
    }
    _flexibleHeight = value;
    markNeedsLayout();
  }

  // TODO(ianh): cacheExtent/cacheExtentStyle should be a single
  // object that specifies both the scalar value and the unit, not a
  // pair of independent setters. Changing that would allow a more
  // rational API and would let us make the getter non-nullable.

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  ///
  /// The getter can never return null, but the field is nullable
  /// because the setter can be set to null to reset the value to
  /// [RenderAbstractViewport.defaultCacheExtent] (in which case
  /// [cacheExtentStyle] must be [CacheExtentStyle.pixel]).
  ///
  /// See also:
  ///
  ///  * [cacheExtentStyle], which controls the units of the [cacheExtent].
  double? get cacheExtent => _cacheExtent;
  double _cacheExtent;
  set cacheExtent(double? value) {
    value ??= RenderAbstractViewport.defaultCacheExtent;
    if (value == _cacheExtent) {
      return;
    }
    _cacheExtent = value;
    markNeedsLayout();
  }

  /// This value is set during layout based on the [CacheExtentStyle].
  ///
  /// When the style is [CacheExtentStyle.viewport], it is the main axis extent
  /// of the viewport multiplied by the requested cache extent, which is still
  /// expressed in pixels.
  double? _calculatedCacheExtent;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtentStyle}
  ///
  /// Changing the [cacheExtentStyle] without also changing the [cacheExtent]
  /// is rarely the correct choice.
  CacheExtentStyle get cacheExtentStyle => _cacheExtentStyle;
  CacheExtentStyle _cacheExtentStyle;
  set cacheExtentStyle(CacheExtentStyle value) {
    if (value == _cacheExtentStyle) {
      return;
    }
    _cacheExtentStyle = value;
    markNeedsLayout();
  }

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.hardEdge;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _offset.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalContainerParentData) {
      child.parentData = SliverPhysicalContainerParentData();
    }
  }

  /// Throws an exception saying that the object does not support returning
  /// intrinsic dimensions if, in debug mode, we are not in the
  /// [RenderObject.debugCheckingIntrinsics] mode.
  ///
  /// This is used by [computeMinIntrinsicWidth] et al because viewports do not
  /// generally support returning intrinsic dimensions. See the discussion at
  /// [computeMinIntrinsicWidth].
  @protected
  bool debugThrowIfNotCheckingIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        assert(this is! RenderShrinkWrappingViewport); // it has its own message
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('$runtimeType does not support returning intrinsic dimensions.'),
          ErrorDescription(
            'Calculating the intrinsic dimensions would require instantiating every child of '
            'the viewport, which defeats the point of viewports being lazy.',
          ),
          ErrorHint(
            'If you are merely trying to shrink-wrap the viewport in the main axis direction, '
            'consider a RenderShrinkWrappingViewport render object (ShrinkWrappingViewport widget), '
            'which achieves that effect without implementing the intrinsic dimension API.',
          ),
        ]);
      }
      return true;
    }());
    return true;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    assert(debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  @protected
  Size computeDryLayout(covariant BoxConstraints constraints) {
    assert(debugCheckHasBoundedAxis(Axis.horizontal, constraints));
    return constraints.biggest;
  }

  static const int _maxLayoutCyclesPerChild = 10;

  // Out-of-band data computed during layout.
  late double _maxScrollExtent;
  double _maxCrossAxisExtent = 0.0;
  late double _shrinkWrapExtent;
  bool _hasVisualOverflow = false;

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;

    if (firstChild == null) {
      assert(firstChild == null);
      size = Size(constraints.minWidth, constraints.maxHeight);
      offset.applyViewportDimension(0.0);
      _maxScrollExtent = 0.0;
      _maxCrossAxisExtent = 0.0;
      _shrinkWrapExtent = 0.0;
      _hasVisualOverflow = false;
      offset.applyContentDimensions(0.0, 0.0);
      return;
    }
    assert(firstChild!.parent == this);

    final double mainAxisExtent = constraints.maxWidth;
    final double crossAxisExtent = constraints.maxHeight;

    final int maxLayoutCycles = _maxLayoutCyclesPerChild * childCount;

    double correction;
    double effectiveExtent;
    int count = 0;
    do {
      correction = _attemptLayout(
        mainAxisExtent,
        crossAxisExtent,
        offset.pixels,
      );
      if (correction != 0.0) {
        offset.correctBy(correction);
      } else {
        effectiveExtent = constraints.constrainWidth(_shrinkWrapExtent);
        final bool didAcceptViewportDimension = offset.applyViewportDimension(effectiveExtent);
        final bool didAcceptContentDimension = offset.applyContentDimensions(
          0.0,
          math.max(0.0, _maxScrollExtent - effectiveExtent),
        );
        if (didAcceptViewportDimension && didAcceptContentDimension) {
          break;
        }
      }
      count += 1;
    } while (count < maxLayoutCycles);
    assert(() {
      if (count >= maxLayoutCycles) {
        assert(count != 1);
        throw FlutterError(
          'A RenderHorizontalViewport exceeded its maximum number of layout cycles.\n'
          'RenderHorizontalViewport render objects, during layout, can retry if either their '
          'slivers or their ViewportOffset decide that the offset should be corrected '
          'to take into account information collected during that layout.\n'
          'In the case of this RenderHorizontalViewport object, however, '
          'this happened $count times and still there was no consensus on the scroll offset. '
          'This usually indicates a bug. Specifically, it means that one of the following '
          'three problems is being experienced by the RenderHorizontalViewport object:\n'
          ' * One of the RenderSliver children or the ViewportOffset have a bug such'
          ' that they always think that they need to correct the offset regardless.\n'
          ' * Some combination of the RenderSliver children and the ViewportOffset'
          ' have a bad interaction such that one applies a correction then another'
          ' applies a reverse correction, leading to an infinite loop of corrections.\n'
          ' * There is a pathological case that would eventually resolve, but it is'
          ' so complicated that it cannot be resolved in any reasonable number of'
          ' layout passes.',
        );
      }
      return true;
    }());

    size = Size(
      constraints.maxWidth,
      constraints.constrainHeight(_maxCrossAxisExtent),
    );
  }

  double _attemptLayout(double mainAxisExtent, double crossAxisExtent, double correctedOffset) {
    assert(!mainAxisExtent.isNaN);
    assert(mainAxisExtent >= 0.0);
    assert(!crossAxisExtent.isNaN);
    assert(crossAxisExtent >= 0.0);
    assert(correctedOffset.isFinite);
    _maxScrollExtent = 0.0;
    _shrinkWrapExtent = 0.0;
    _hasVisualOverflow = false;

    _calculatedCacheExtent = switch (cacheExtentStyle) {
      CacheExtentStyle.pixel => cacheExtent,
      CacheExtentStyle.viewport => mainAxisExtent * _cacheExtent,
    };

    final double fullCacheExtent = mainAxisExtent + 2 * _calculatedCacheExtent!;
    final double currentCacheOffset = -correctedOffset + _calculatedCacheExtent!;
    final double forwardDirectionRemainingCacheExtent = clampDouble(
      fullCacheExtent - currentCacheOffset,
      0.0,
      fullCacheExtent,
    );

    // positive scroll offsets
    return layoutChildSequence(
      child: firstChild,
      scrollOffset: math.max(0.0, correctedOffset),
      overlap: math.min(0.0, correctedOffset),
      layoutOffset: math.max(0.0, -correctedOffset),
      remainingPaintExtent: mainAxisExtent + math.min(0.0, correctedOffset),
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
      growthDirection: GrowthDirection.forward,
      advance: childAfter,
      remainingCacheExtent: forwardDirectionRemainingCacheExtent,
      cacheOrigin: clampDouble(-correctedOffset, -_calculatedCacheExtent!, 0.0),
    );
  }

  /// Determines the size and position of some of the children of the viewport.
  ///
  /// This function is the workhorse of `performLayout` implementations in
  /// subclasses.
  ///
  /// Layout starts with `child`, proceeds according to the `advance` callback,
  /// and stops once `advance` returns null.
  ///
  ///  * `scrollOffset` is the [SliverConstraints.scrollOffset] to pass the
  ///    first child. The scroll offset is adjusted by
  ///    [SliverGeometry.scrollExtent] for subsequent children.
  ///  * `overlap` is the [SliverConstraints.overlap] to pass the first child.
  ///    The overlay is adjusted by the [SliverGeometry.paintOrigin] and
  ///    [SliverGeometry.paintExtent] for subsequent children.
  ///  * `layoutOffset` is the layout offset at which to place the first child.
  ///    The layout offset is updated by the [SliverGeometry.layoutExtent] for
  ///    subsequent children.
  ///  * `remainingPaintExtent` is [SliverConstraints.remainingPaintExtent] to
  ///    pass the first child. The remaining paint extent is updated by the
  ///    [SliverGeometry.layoutExtent] for subsequent children.
  ///  * `mainAxisExtent` is the [SliverConstraints.viewportMainAxisExtent] to
  ///    pass to each child.
  ///  * `crossAxisExtent` is the [SliverConstraints.crossAxisExtent] to pass to
  ///    each child.
  ///  * `growthDirection` is the [SliverConstraints.growthDirection] to pass to
  ///    each child.
  ///
  /// Returns the first non-zero [SliverGeometry.scrollOffsetCorrection]
  /// encountered, if any. Otherwise returns 0.0. Typical callers will call this
  /// function repeatedly until it returns 0.0.
  @protected
  double layoutChildSequence({
    required RenderSliver? child,
    required double scrollOffset,
    required double overlap,
    required double layoutOffset,
    required double remainingPaintExtent,
    required double mainAxisExtent,
    required double crossAxisExtent,
    required GrowthDirection growthDirection,
    required RenderSliver? Function(RenderSliver child) advance,
    required double remainingCacheExtent,
    required double cacheOrigin,
  }) {
    assert(scrollOffset.isFinite);
    assert(scrollOffset >= 0.0);
    final double initialLayoutOffset = layoutOffset;
    final ScrollDirection adjustedUserScrollDirection = applyGrowthDirectionToScrollDirection(
      offset.userScrollDirection,
      growthDirection,
    );
    double maxPaintOffset = layoutOffset + overlap;
    double precedingScrollExtent = 0.0;

    while (child != null) {
      final double sliverScrollOffset = scrollOffset <= 0.0 ? 0.0 : scrollOffset;
      // If the scrollOffset is too small we adjust the paddedOrigin because it
      // doesn't make sense to ask a sliver for content before its scroll
      // offset.
      final double correctedCacheOrigin = math.max(cacheOrigin, -sliverScrollOffset);
      final double cacheExtentCorrection = cacheOrigin - correctedCacheOrigin;

      assert(sliverScrollOffset >= correctedCacheOrigin.abs());
      assert(correctedCacheOrigin <= 0.0);
      assert(sliverScrollOffset >= 0.0);
      assert(cacheExtentCorrection <= 0.0);

      child.layout(
        SliverConstraints(
          axisDirection: horizontalAxisDirectionToAxisDirection(axisDirection),
          growthDirection: growthDirection,
          userScrollDirection: adjustedUserScrollDirection,
          scrollOffset: sliverScrollOffset,
          precedingScrollExtent: precedingScrollExtent,
          overlap: maxPaintOffset - layoutOffset,
          remainingPaintExtent: math.max(
            0.0,
            remainingPaintExtent - layoutOffset + initialLayoutOffset,
          ),
          crossAxisExtent: crossAxisExtent,
          crossAxisDirection: AxisDirection.down,
          viewportMainAxisExtent: mainAxisExtent,
          remainingCacheExtent: math.max(0.0, remainingCacheExtent + cacheExtentCorrection),
          cacheOrigin: correctedCacheOrigin,
        ),
        parentUsesSize: true,
      );

      final SliverGeometry childLayoutGeometry = child.geometry!;
      assert(childLayoutGeometry.debugAssertIsValid());

      // If there is a correction to apply, we'll have to start over.
      if (childLayoutGeometry.scrollOffsetCorrection != null) {
        return childLayoutGeometry.scrollOffsetCorrection!;
      }

      // We use the child's paint origin in our coordinate system as the
      // layoutOffset we store in the child's parent data.
      final double effectiveLayoutOffset = layoutOffset + childLayoutGeometry.paintOrigin;

      // `effectiveLayoutOffset` becomes meaningless once we moved past the trailing edge
      // because `childLayoutGeometry.layoutExtent` is zero. Using the still increasing
      // 'scrollOffset` to roughly position these invisible slivers in the right order.
      if (childLayoutGeometry.visible || scrollOffset > 0) {
        updateChildLayoutOffset(child, mainAxisExtent, effectiveLayoutOffset, growthDirection);
      } else {
        updateChildLayoutOffset(child, mainAxisExtent, -scrollOffset + initialLayoutOffset, growthDirection);
      }

      maxPaintOffset = math.max(
        effectiveLayoutOffset + childLayoutGeometry.paintExtent,
        maxPaintOffset,
      );
      scrollOffset -= childLayoutGeometry.scrollExtent;
      precedingScrollExtent += childLayoutGeometry.scrollExtent;
      layoutOffset += childLayoutGeometry.layoutExtent;
      if (childLayoutGeometry.cacheExtent != 0.0) {
        remainingCacheExtent -= childLayoutGeometry.cacheExtent - cacheExtentCorrection;
        cacheOrigin = math.min(correctedCacheOrigin + childLayoutGeometry.cacheExtent, 0.0);
      }

      updateOutOfBandData(growthDirection, childLayoutGeometry);

      // move on to the next child
      child = advance(child);
    }

    // we made it without a correction, whee!
    return 0.0;
  }

  bool get hasVisualOverflow => _hasVisualOverflow;

  void updateOutOfBandData(GrowthDirection growthDirection, SliverGeometry childLayoutGeometry) {
    assert(growthDirection == GrowthDirection.forward);
    _maxScrollExtent += childLayoutGeometry.scrollExtent;
    if (childLayoutGeometry.hasVisualOverflow) {
      _hasVisualOverflow = true;
    }
    final crossAxisExtent = childLayoutGeometry.crossAxisExtent;
    if (crossAxisExtent != null) {
      if (flexibleHeight) {
        _maxCrossAxisExtent = crossAxisExtent;
      } else {
        _maxCrossAxisExtent = math.max(_maxCrossAxisExtent, crossAxisExtent);
      }
    }
    _shrinkWrapExtent += childLayoutGeometry.maxPaintExtent;
  }

  void updateChildLayoutOffset(
    RenderSliver child,
    double mainAxisExtent,
    double layoutOffset,
    GrowthDirection growthDirection,
  ) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.paintOffset = computeAbsolutePaintOffset(child, mainAxisExtent, layoutOffset, growthDirection);
  }

  Offset paintOffsetOf(RenderSliver child) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    return childParentData.paintOffset;
  }

  double scrollOffsetOf(RenderSliver child, double scrollOffsetWithinChild) {
    assert(child.parent == this);
    final GrowthDirection growthDirection = child.constraints.growthDirection;
    switch (growthDirection) {
      case GrowthDirection.forward:
        double scrollOffsetToChild = 0.0;
        RenderSliver? current = firstChild;
        while (current != child) {
          scrollOffsetToChild += current!.geometry!.scrollExtent;
          current = childAfter(current);
        }
        return scrollOffsetToChild + scrollOffsetWithinChild;
      case GrowthDirection.reverse:
        double scrollOffsetToChild = 0.0;
        RenderSliver? current = childBefore(firstChild!);
        while (current != child) {
          scrollOffsetToChild -= current!.geometry!.scrollExtent;
          current = childBefore(current);
        }
        return scrollOffsetToChild - scrollOffsetWithinChild;
    }
  }

  double maxScrollObstructionExtentBefore(RenderSliver child) {
    assert(child.parent == this);
    final GrowthDirection growthDirection = child.constraints.growthDirection;
    switch (growthDirection) {
      case GrowthDirection.forward:
        double pinnedExtent = 0.0;
        RenderSliver? current = firstChild;
        while (current != child) {
          pinnedExtent += current!.geometry!.maxScrollObstructionExtent;
          current = childAfter(current);
        }
        return pinnedExtent;
      case GrowthDirection.reverse:
        double pinnedExtent = 0.0;
        RenderSliver? current = childBefore(firstChild!);
        while (current != child) {
          pinnedExtent += current!.geometry!.maxScrollObstructionExtent;
          current = childBefore(current);
        }
        return pinnedExtent;
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    // Hit test logic relies on this always providing an invertible matrix.
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  double computeChildMainAxisPosition(RenderSliver child, double parentMainAxisPosition) {
    final Offset paintOffset = (child.parentData! as SliverPhysicalParentData).paintOffset;
    return switch (applyGrowthDirectionToAxisDirection(
      child.constraints.axisDirection,
      child.constraints.growthDirection,
    )) {
      HorizontalAxisDirection.right => parentMainAxisPosition - paintOffset.dx,
      HorizontalAxisDirection.left => child.geometry!.paintExtent - (parentMainAxisPosition - paintOffset.dx),
    };
  }

  int get indexOfFirstChild {
    assert(firstChild != null);
    assert(firstChild!.parent == this);
    assert(firstChild != null);
    return 0;
  }

  String labelForChild(int index) {
    if (index == 0) {
      return 'first child';
    }
    return 'child $index';
  }

  Iterable<RenderSliver> get childrenInPaintOrder {
    final List<RenderSliver> children = <RenderSliver>[];
    RenderSliver? child = lastChild;
    while (child != null) {
      children.add(child);
      child = childBefore(child);
    }
    return children;
  }

  Iterable<RenderSliver> get childrenInHitTestOrder {
    final List<RenderSliver> children = <RenderSliver>[];
    RenderSliver? child = firstChild;
    while (child != null) {
      children.add(child);
      child = childAfter(child);
    }
    return children;
  }

  @override
  Rect? describeApproximatePaintClip(RenderSliver child) {
    switch (clipBehavior) {
      case Clip.none:
        return null;
      case Clip.hardEdge:
      case Clip.antiAlias:
      case Clip.antiAliasWithSaveLayer:
        break;
    }

    final Rect viewportClip = Offset.zero & size;
    // The child's viewportMainAxisExtent can be infinite when a
    // RenderShrinkWrappingViewport is given infinite constraints, such as when
    // it is the child of a Row or Column (depending on orientation).
    //
    // For example, a shrink wrapping render sliver may have infinite
    // constraints along the viewport's main axis but may also have bouncing
    // scroll physics, which will allow for some scrolling effect to occur.
    // We should just use the viewportClip - the start of the overlap is at
    // double.infinity and so it is effectively meaningless.
    if (child.constraints.overlap == 0 || !child.constraints.viewportMainAxisExtent.isFinite) {
      return viewportClip;
    }

    // Adjust the clip rect for this sliver by the overlap from the previous sliver.
    double left = viewportClip.left;
    double right = viewportClip.right;
    double top = viewportClip.top;
    double bottom = viewportClip.bottom;
    final double startOfOverlap =
        child.constraints.viewportMainAxisExtent - child.constraints.remainingPaintExtent;
    final double overlapCorrection = startOfOverlap + child.constraints.overlap;
    switch (applyGrowthDirectionToHorizontalAxisDirection(axisDirection, child.constraints.growthDirection)) {
      case HorizontalAxisDirection.right:
        left += overlapCorrection;
      case HorizontalAxisDirection.left:
        right -= overlapCorrection;
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  Rect? describeSemanticsClip(RenderSliver? child) {
    if (_calculatedCacheExtent == null) {
      return semanticBounds;
    }

    return Rect.fromLTRB(
      semanticBounds.left - _calculatedCacheExtent!,
      semanticBounds.top,
      semanticBounds.right + _calculatedCacheExtent!,
      semanticBounds.bottom,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null) {
      return;
    }
    if (hasVisualOverflow && clipBehavior != Clip.none) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        _paintContents,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      _paintContents(context, offset);
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  void _paintContents(PaintingContext context, Offset offset) {
    for (final RenderSliver child in childrenInPaintOrder) {
      if (child.geometry!.visible) {
        context.paintChild(child, offset + paintOffsetOf(child));
      }
    }
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      super.debugPaintSize(context, offset);
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFF00FF00);
      final Canvas canvas = context.canvas;
      RenderSliver? child = firstChild;
      while (child != null) {
        final Size size = Size(child.geometry!.layoutExtent, child.constraints.crossAxisExtent);
        canvas.drawRect(((offset + paintOffsetOf(child)) & size).deflate(0.5), paint);
        child = childAfter(child);
      }
      return true;
    }());
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final double mainAxisPosition = position.dx;
    final double crossAxisPosition = position.dy;
    final SliverHitTestResult sliverResult = SliverHitTestResult.wrap(result);
    for (final RenderSliver child in childrenInHitTestOrder) {
      if (!child.geometry!.visible) {
        continue;
      }
      final Matrix4 transform = Matrix4.identity();
      applyPaintTransform(child, transform); // must be invertible
      final bool isHit = result.addWithOutOfBandPosition(
        paintTransform: transform,
        hitTest: (BoxHitTestResult result) {
          return child.hitTest(
            sliverResult,
            mainAxisPosition: computeChildMainAxisPosition(child, mainAxisPosition),
            crossAxisPosition: crossAxisPosition,
          );
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }

  @override
  RevealedOffset getOffsetToReveal(
    RenderObject target,
    double alignment, {
    Rect? rect,
    Axis? axis,
  }) {
    // One dimensional viewport has only one axis, override if it was
    // provided/may be mismatched.
    axis = Axis.horizontal;

    // Steps to convert `rect` (from a RenderBox coordinate system) to its
    // scroll offset within this viewport (not in the exact order):
    //
    // 1. Pick the outermost RenderBox (between which, and the viewport, there
    // is nothing but RenderSlivers) as an intermediate reference frame
    // (the `pivot`), convert `rect` to that coordinate space.
    //
    // 2. Convert `rect` from the `pivot` coordinate space to its sliver
    // parent's sliver coordinate system (i.e., to a scroll offset), based on
    // the axis direction and growth direction of the parent.
    //
    // 3. Convert the scroll offset to its sliver parent's coordinate space
    // using `childScrollOffset`, until we reach the viewport.
    //
    // 4. Make the final conversion from the outmost sliver to the viewport
    // using `scrollOffsetOf`.

    double leadingScrollOffset = 0.0;
    // Starting at `target` and walking towards the root:
    //  - `child` will be the last object before we reach this viewport, and
    //  - `pivot` will be the last RenderBox before we reach this viewport.
    RenderObject child = target;
    RenderBox? pivot;
    bool onlySlivers =
        target is RenderSliver; // ... between viewport and `target` (`target` included).
    while (child.parent != this) {
      final RenderObject parent = child.parent!;
      if (child is RenderBox) {
        pivot = child;
      }
      if (parent is RenderSliver) {
        leadingScrollOffset += parent.childScrollOffset(child)!;
      } else {
        onlySlivers = false;
        leadingScrollOffset = 0.0;
      }
      child = parent;
    }

    // `rect` in the new intermediate coordinate system.
    final Rect rectLocal;
    // Our new reference frame render object's main axis extent.
    final double pivotExtent;
    final GrowthDirection growthDirection;

    // `leadingScrollOffset` is currently the scrollOffset of our new reference
    // frame (`pivot` or `target`), within `child`.
    if (pivot != null) {
      assert(pivot.parent != null);
      assert(pivot.parent != this);
      assert(pivot != this);
      assert(
        pivot.parent is RenderSliver,
      ); // TODO(abarth): Support other kinds of render objects besides slivers.
      final RenderSliver pivotParent = pivot.parent! as RenderSliver;
      growthDirection = pivotParent.constraints.growthDirection;
      pivotExtent = pivot.size.width;
      rect ??= target.paintBounds;
      rectLocal = MatrixUtils.transformRect(target.getTransformTo(pivot), rect);
    } else if (onlySlivers) {
      // `pivot` does not exist. We'll have to make up one from `target`, the
      // innermost sliver.
      final RenderSliver targetSliver = target as RenderSliver;
      growthDirection = targetSliver.constraints.growthDirection;
      // TODO(LongCatIsLooong): make sure this works if `targetSliver` is a
      // persistent header, when #56413 relands.
      pivotExtent = targetSliver.geometry!.scrollExtent;
      rect ??= Rect.fromLTWH(
        0,
        0,
        targetSliver.geometry!.scrollExtent,
        targetSliver.constraints.crossAxisExtent,
      );
      rectLocal = rect;
    } else {
      assert(rect != null);
      return RevealedOffset(offset: offset.pixels, rect: rect!);
    }

    assert(child.parent == this);
    assert(child is RenderSliver);
    final RenderSliver sliver = child as RenderSliver;

    // The scroll offset of `rect` within `child`.
    leadingScrollOffset += switch (applyGrowthDirectionToHorizontalAxisDirection(
      axisDirection,
      growthDirection,
    )) {
      HorizontalAxisDirection.left => pivotExtent - rectLocal.right,
      HorizontalAxisDirection.right => rectLocal.left,
    };

    // So far leadingScrollOffset is the scroll offset of `rect` in the `child`
    // sliver's sliver coordinate system. The sign of this value indicates
    // whether the `rect` protrudes the leading edge of the `child` sliver. When
    // this value is non-negative and `child`'s `maxScrollObstructionExtent` is
    // greater than 0, we assume `rect` can't be obstructed by the leading edge
    // of the viewport (i.e. its pinned to the leading edge).
    final bool isPinned =
        sliver.geometry!.maxScrollObstructionExtent > 0 && leadingScrollOffset >= 0;

    // The scroll offset in the viewport to `rect`.
    leadingScrollOffset = scrollOffsetOf(sliver, leadingScrollOffset);

    // This step assumes the viewport's layout is up-to-date, i.e., if
    // offset.pixels is changed after the last performLayout, the new scroll
    // position will not be accounted for.
    final Matrix4 transform = target.getTransformTo(this);
    Rect targetRect = MatrixUtils.transformRect(transform, rect);
    final double extentOfPinnedSlivers = maxScrollObstructionExtentBefore(sliver);

    switch (sliver.constraints.growthDirection) {
      case GrowthDirection.forward:
        if (isPinned && alignment <= 0) {
          return RevealedOffset(offset: double.infinity, rect: targetRect);
        }
        leadingScrollOffset -= extentOfPinnedSlivers;
      case GrowthDirection.reverse:
        if (isPinned && alignment >= 1) {
          return RevealedOffset(offset: double.negativeInfinity, rect: targetRect);
        }
        // If child's growth direction is reverse, when viewport.offset is
        // `leadingScrollOffset`, it is positioned just outside of the leading
        // edge of the viewport.
        leadingScrollOffset -= switch (axis) {
          Axis.vertical => targetRect.height,
          Axis.horizontal => targetRect.width,
        };
    }

    final double mainAxisExtentDifference = size.width - extentOfPinnedSlivers - rectLocal.width;

    final double targetOffset = leadingScrollOffset - mainAxisExtentDifference * alignment;
    final double offsetDifference = offset.pixels - targetOffset;

    targetRect = switch (axisDirection) {
      HorizontalAxisDirection.left => targetRect.translate(-offsetDifference, 0.0),
      HorizontalAxisDirection.right => targetRect.translate(offsetDifference, 0.0),
    };

    return RevealedOffset(offset: targetOffset, rect: targetRect);
  }

  /// The offset at which the given `child` should be painted.
  ///
  /// The returned offset is from the top left corner of the inside of the
  /// viewport to the top left corner of the paint coordinate system of the
  /// `child`.
  ///
  /// See also:
  ///
  ///  * [paintOffsetOf], which uses the layout offset and growth direction
  ///    computed for the child during layout.
  @protected
  Offset computeAbsolutePaintOffset(
    RenderSliver child,
    double mainAxisExtent,
    double layoutOffset,
    GrowthDirection growthDirection,
  ) {
    assert(child.geometry != null);
    return switch (applyGrowthDirectionToHorizontalAxisDirection(axisDirection, growthDirection)) {
      HorizontalAxisDirection.left => Offset(mainAxisExtent - layoutOffset - child.geometry!.paintExtent, 0.0),
      HorizontalAxisDirection.right => Offset(layoutOffset, 0.0),
    };
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HorizontalAxisDirection>('axisDirection', axisDirection));
    properties.add(DiagnosticsProperty<ViewportOffset>('offset', offset));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    RenderSliver? child = firstChild;
    if (child == null) {
      return children;
    }

    int count = indexOfFirstChild;
    while (true) {
      children.add(child!.toDiagnosticsNode(name: labelForChild(count)));
      if (child == lastChild) {
        break;
      }
      count += 1;
      child = childAfter(child);
    }
    return children;
  }
}

/// A scrollable list of widgets arranged linearly.
///
/// [HorizontalListView] displays its children one after another.
///
/// Unlike [ListView], [HorizontalListView] needs to perform layout
/// on its children to obtain their height. The children can be laid out
/// without any constraints to get their "natural" size. Hence,
/// if a child uses alignment widgets like [Center] or [Align], it will not
/// expand to fill the height of this widget. Because each child must be
/// laid out individually to determine its height, the `itemExtent` and
/// `itemExtentBuilder` properties are not supported.
///
/// If non-null, the [prototypeItem] forces the children to have the same size
/// as the given widget.
///
/// Specifying an [prototypeItem] is more efficient than
/// letting the children determine their own size because the scrolling
/// machinery can make use of the foreknowledge of the children's size to save
/// work, for example when the scroll position changes drastically.
///
/// There are four options for constructing a [HorizontalListView]:
///
///  1. The default constructor takes an explicit [List<Widget>] of children. This
///     constructor is appropriate for list views with a small number of
///     children because constructing the [List] requires doing work for every
///     child that could possibly be displayed in the list view instead of just
///     those children that are actually visible.
///
///  2. The [HorizontalListView.builder] constructor takes an [IndexedWidgetBuilder],
///     which builds the children on demand. This constructor is appropriate for list views
///     with a large (or infinite) number of children because the builder is called
///     only for those children that are actually visible.
///
///  3. The [HorizontalListView.separated] constructor takes two [IndexedWidgetBuilder]s:
///     `itemBuilder` builds child items on demand, and `separatorBuilder`
///     similarly builds separator children which appear in between the child items.
///     This constructor is appropriate for list views with a fixed number of children.
///
///  4. The [HorizontalListView.custom] constructor takes a [SliverChildDelegate], which provides
///     the ability to customize additional aspects of the child model. For example,
///     a [SliverChildDelegate] can control the algorithm used to estimate the
///     size of children that are not actually visible.
///
/// To control the initial scroll offset of the scroll view, provide a
/// [controller] with its [ScrollController.initialScrollOffset] property set.
///
/// By default, [HorizontalListView] will automatically pad the list's scrollable
/// extremities to avoid partial obstructions indicated by [MediaQuery]'s
/// padding. To avoid this behavior, override with a zero [padding] property.
///
/// ## Child elements' lifecycle
///
/// ### Creation
///
/// While laying out the list, visible children's elements, states and render
/// objects will be created lazily based on existing widgets (such as when using
/// the default constructor) or lazily provided ones (such as when using the
/// [HorizontalListView.builder] constructor).
///
/// ### Destruction
///
/// When a child is scrolled out of view, the associated element subtree,
/// states and render objects are destroyed. A new child at the same position
/// in the list will be lazily recreated along with new elements, states and
/// render objects when it is scrolled back.
///
/// ### Destruction mitigation
///
/// In order to preserve state as child elements are scrolled in and out of
/// view, the following options are possible:
///
///  * Moving the ownership of non-trivial UI-state-driving business logic
///    out of the list child subtree. For instance, if a list contains posts
///    with their number of upvotes coming from a cached network response, store
///    the list of posts and upvote number in a data model outside the list. Let
///    the list child UI subtree be easily recreate-able from the
///    source-of-truth model object. Use [StatefulWidget]s in the child
///    widget subtree to store instantaneous UI state only.
///
///  * Letting [KeepAlive] be the root widget of the list child widget subtree
///    that needs to be preserved. The [KeepAlive] widget marks the child
///    subtree's top render object child for keepalive. When the associated top
///    render object is scrolled out of view, the list keeps the child's render
///    object (and by extension, its associated elements and states) in a cache
///    list instead of destroying them. When scrolled back into view, the render
///    object is repainted as-is (if it wasn't marked dirty in the interim).
///
///    This only works if `addAutomaticKeepAlives` and `addRepaintBoundaries`
///    are false since those parameters cause the [HorizontalListView] to wrap
///    each child widget subtree with other widgets.
///
///  * Using [AutomaticKeepAlive] widgets (inserted by default when
///    `addAutomaticKeepAlives` is true). [AutomaticKeepAlive] allows descendant
///    widgets to control whether the subtree is actually kept alive or not.
///    This behavior is in contrast with [KeepAlive], which will unconditionally keep
///    the subtree alive.
///
///    As an example, the [EditableText] widget signals its list child element
///    subtree to stay alive while its text field has input focus. If it doesn't
///    have focus and no other descendants signaled for keepalive via a
///    [KeepAliveNotification], the list child element subtree will be destroyed
///    when scrolled away.
///
///    [AutomaticKeepAlive] descendants typically signal it to be kept alive
///    by using the [AutomaticKeepAliveClientMixin], then implementing the
///    [AutomaticKeepAliveClientMixin.wantKeepAlive] getter and calling
///    [AutomaticKeepAliveClientMixin.updateKeepAlive].
///
/// ## Special handling for an empty list
///
/// A common design pattern is to have a custom UI for an empty list. The best
/// way to achieve this in Flutter is just conditionally replacing the
/// [HorizontalListView] at build time with whatever widgets you need to show
/// for the empty list state:
///
/// {@tool snippet}
///
/// Example of simple empty list interface:
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: AppBar(title: const Text('Empty List Test')),
///     body: itemCount > 0
///       ? HorizontalListView.builder(
///           itemCount: itemCount,
///           itemBuilder: (BuildContext context, int index) {
///             return ListTile(
///               title: Text('Item ${index + 1}'),
///             );
///           },
///         )
///       : const Center(child: Text('No items')),
///   );
/// }
/// ```
/// {@end-tool}
///
/// {@macro flutter.widgets.BoxScroll.scrollBehaviour}
///
/// {@macro flutter.widgets.ScrollView.PageStorage}
///
/// See also:
///
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
class HorizontalListView extends HorizontalScrollView {
  /// Creates a scrollable, linear array of widgets from an explicit [List].
  ///
  /// This constructor is appropriate for list views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the list view instead of just
  /// those children that are actually visible.
  ///
  /// Like other widgets in the Flutter framework, this widget expects that
  /// the [children] list will not be mutated after it has been passed in here.
  /// See the documentation at [SliverChildListDelegate.children] for more details.
  ///
  /// It is usually more efficient to create children on demand using
  /// [HorizontalListView.builder] because it will create the widget children
  /// lazily as necessary.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildListDelegate.addRepaintBoundaries] property. The
  /// `addSemanticIndexes` argument corresponds to the
  /// [SliverChildListDelegate.addSemanticIndexes] property. None
  /// may be null.
  HorizontalListView({
    super.key,
    super.reverse,
    super.controller,
    super.physics,
    super.flexibleHeight,
    this.padding,
    this.prototypeItem,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.cacheExtent,
    List<Widget> children = const <Widget>[],
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
  }) : childrenDelegate = SliverChildListDelegate(
         children,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       ),
       super(semanticChildCount: semanticChildCount ?? children.length);

  /// Creates a scrollable, linear array of widgets that are created on demand.
  ///
  /// This constructor is appropriate for list views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null `itemCount` improves the ability of
  /// the [HorizontalListView] to estimate the maximum scroll extent.
  ///
  /// The `itemBuilder` callback will be called only with indices greater than
  /// or equal to zero and less than `itemCount`.
  ///
  /// {@macro flutter.widgets.ListView.builder.itemBuilder}
  ///
  /// The `itemBuilder` should always create the widget instances when called.
  /// Avoid using a builder that returns a previously-constructed widget; if the
  /// list view's children are created in advance, or all at once when the
  /// [HorizontalListView] itself is created, it is more efficient to use
  /// the [HorizontalListView] constructor. Even more efficient, however,
  /// is to create the instances on demand using this constructor's `itemBuilder` callback.
  ///
  /// {@macro flutter.widgets.PageView.findChildIndexCallback}
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. The
  /// `addSemanticIndexes` argument corresponds to the
  /// [SliverChildBuilderDelegate.addSemanticIndexes] property. None may be
  /// null.
  HorizontalListView.builder({
    super.key,
    super.reverse,
    super.controller,
    super.physics,
    super.flexibleHeight,
    this.padding,
    this.prototypeItem,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.cacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
  }) : assert(itemCount == null || itemCount >= 0),
       assert(semanticChildCount == null || semanticChildCount <= itemCount!),
       childrenDelegate = SliverChildBuilderDelegate(
         itemBuilder,
         findChildIndexCallback: findChildIndexCallback,
         childCount: itemCount,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       ),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  /// Creates a fixed-length scrollable linear array of list "items" separated
  /// by list item "separators".
  ///
  /// This constructor is appropriate for list views with a large number of
  /// item and separator children because the builders are only called for
  /// the children that are actually visible.
  ///
  /// The `itemBuilder` callback will be called with indices greater than
  /// or equal to zero and less than `itemCount`.
  ///
  /// Separators only appear between list items: separator 0 appears after item
  /// 0 and the last separator appears before the last item.
  ///
  /// The `separatorBuilder` callback will be called with indices greater than
  /// or equal to zero and less than `itemCount - 1`.
  ///
  /// The `itemBuilder` and `separatorBuilder` callbacks should always
  /// actually create widget instances when called. Avoid using a builder that
  /// returns a previously-constructed widget; if the list view's children are
  /// created in advance, or all at once when the [HorizontalListView] itself
  /// is created, it is more efficient to use the [HorizontalListView] constructor.
  ///
  /// {@macro flutter.widgets.ListView.builder.itemBuilder}
  ///
  /// {@macro flutter.widgets.PageView.findChildIndexCallback}
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. The
  /// `addSemanticIndexes` argument corresponds to the
  /// [SliverChildBuilderDelegate.addSemanticIndexes] property. None may be
  /// null.
  HorizontalListView.separated({
    super.key,
    super.reverse,
    super.controller,
    super.physics,
    super.flexibleHeight,
    this.padding,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.cacheExtent,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
  }) : assert(itemCount >= 0),
       prototypeItem = null,
       childrenDelegate = SliverChildBuilderDelegate(
         (BuildContext context, int index) {
           final int itemIndex = index ~/ 2;
           if (index.isEven) {
             return itemBuilder(context, itemIndex);
           }
           return separatorBuilder(context, itemIndex);
         },
         findChildIndexCallback: findChildIndexCallback,
         childCount: _computeActualChildCount(itemCount),
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
         semanticIndexCallback: (Widget widget, int index) {
           return index.isEven ? index ~/ 2 : null;
         },
       ),
       super(semanticChildCount: itemCount);

  /// Creates a scrollable, linear array of widgets with a custom child model.
  ///
  /// For example, a custom child model can control the algorithm used to
  /// estimate the size of children that are not actually visible.
  const HorizontalListView.custom({
    super.key,
    super.reverse,
    super.controller,
    super.physics,
    super.flexibleHeight,
    this.padding,
    this.prototypeItem,
    required this.childrenDelegate,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
  });

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// If non-null, forces the children to have the same size
  /// as the given widget.
  ///
  /// Specifying an prototypeItem is more efficient than
  /// letting the children determine their own size because the scrolling
  /// machinery can make use of the foreknowledge of the children's size to save
  /// work, for example when the scroll position changes drastically.
  final Widget? prototypeItem;

  /// A delegate that provides the children for the [HorizontalListView].
  ///
  /// The [HorizontalListView.custom] constructor lets you specify this delegate
  /// explicitly. The [HorizontalListView] and [HorizontalListView.builder] constructors
  /// create a [childrenDelegate] that wraps the given [List] and [IndexedWidgetBuilder],
  /// respectively.
  final SliverChildDelegate childrenDelegate;

  @override
  List<Widget> buildSlivers(BuildContext context) {
    Widget sliver = buildChildLayout(context);
    EdgeInsetsGeometry? effectivePadding = padding;
    if (padding == null) {
      final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery != null) {
        // Automatically pad sliver with padding from MediaQuery.
        final EdgeInsets mediaQueryHorizontalPadding = mediaQuery.padding.copyWith(
          top: 0.0,
          bottom: 0.0,
        );
        final EdgeInsets mediaQueryVerticalPadding = mediaQuery.padding.copyWith(
          left: 0.0,
          right: 0.0,
        );
        // Consume the main axis padding with SliverPadding.
        effectivePadding = mediaQueryHorizontalPadding;
        // Leave behind the cross axis padding.
        sliver = MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQueryVerticalPadding,
          ),
          child: sliver,
        );
      }
    }

    if (effectivePadding != null) {
      sliver = _SliverPadding(padding: effectivePadding, sliver: sliver);
    }
    return <Widget>[sliver];
  }

  Widget buildChildLayout(BuildContext context) {
    if (prototypeItem != null) {
      return SliverPrototypeList(delegate: childrenDelegate, prototypeItem: prototypeItem!);
    }
    return UnconstrainedSliverList(delegate: childrenDelegate);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding, defaultValue: null));
  }

  // Helper method to compute the actual child count for the separated constructor.
  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }
}

/// A sliver that applies padding on each side of another sliver.
///
/// A [_SliverPadding] is a basic sliver that insets another sliver by applying
/// padding on each side.
///
/// See also:
///
///  * [Padding], the box version of this widget.
class _SliverPadding extends SingleChildRenderObjectWidget {
  /// Creates a sliver that applies padding on each side of another sliver.
  const _SliverPadding({required this.padding, Widget? sliver}) : super(child: sliver);

  /// The amount of space by which to inset the child sliver.
  final EdgeInsetsGeometry padding;

  @override
  _RenderSliverPadding createRenderObject(BuildContext context) {
    return _RenderSliverPadding(padding: padding, textDirection: Directionality.of(context));
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSliverPadding renderObject) {
    renderObject
      ..padding = padding
      ..textDirection = Directionality.of(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  }
}

/// Insets a [RenderSliver], applying padding on each side.
///
/// A [_RenderSliverPadding] object wraps the [SliverGeometry.layoutExtent] of
/// its child. Any incoming [SliverConstraints.overlap] is ignored and not
/// passed on to the child.
///
/// This implementation, however, sets the [SliverGeometry.crossAxisExtent]
/// based on the child's layout geometry.
///
/// If the cross-axis constraint is finite, the value is taken
/// directly from the child's [SliverGeometry.crossAxisExtent]. If the
/// constraint is infinite, the total padding in the cross-axis direction is
/// added to the child's cross-axis extent to compute the final value.
///
/// This ensures that the cross-axis extent is reported up
/// the render object tree, which is useful for [RenderUnconstrainedSliverList]
/// that need the [_RenderSliverPadding] to report its cross-axis size.
class _RenderSliverPadding extends RenderSliver
    with RenderObjectWithChildMixin<RenderSliver> {
  /// Creates a render object that insets its child in a viewport.
  ///
  /// The [padding] argument must have non-negative insets.
  _RenderSliverPadding({
    required EdgeInsetsGeometry padding,
    TextDirection? textDirection,
    RenderSliver? child,
  }) : assert(padding.isNonNegative),
       _padding = padding,
       _textDirection = textDirection {
    this.child = child;
  }

  /// The amount to pad the child in each dimension.
  ///
  /// The offsets are specified in terms of visual edges, left, top, right, and
  /// bottom. These values are not affected by the [TextDirection].
  ///
  /// Must not be null or contain negative values when [performLayout] is called.
  EdgeInsets? get resolvedPadding => _resolvedPadding;
  EdgeInsets? _resolvedPadding;

  /// The padding in the scroll direction on the side nearest the 0.0 scroll direction.
  ///
  /// Only valid after layout has started, since before layout the render object
  /// doesn't know what direction it will be laid out in.
  double get beforePadding {
    assert(resolvedPadding != null);
    return switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      HorizontalAxisDirection.right => resolvedPadding!.left,
      HorizontalAxisDirection.left => resolvedPadding!.right,
    };
  }

  /// The padding in the scroll direction on the side furthest from the 0.0 scroll offset.
  ///
  /// Only valid after layout has started, since before layout the render object
  /// doesn't know what direction it will be laid out in.
  double get afterPadding {
    assert(resolvedPadding != null);
    return switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      HorizontalAxisDirection.right => resolvedPadding!.right,
      HorizontalAxisDirection.left => resolvedPadding!.left,
    };
  }

  /// The total padding in the [SliverConstraints.axisDirection]. (In other
  /// words, for a vertical downwards-growing list, the sum of the padding on
  /// the top and bottom.)
  ///
  /// Only valid after layout has started, since before layout the render object
  /// doesn't know what direction it will be laid out in.
  double get mainAxisPadding {
    assert(resolvedPadding != null);
    return resolvedPadding!.along(constraints.axis);
  }

  /// The total padding in the cross-axis direction. (In other words, for a
  /// vertical downwards-growing list, the sum of the padding on the left and
  /// right.)
  ///
  /// Only valid after layout has started, since before layout the render object
  /// doesn't know what direction it will be laid out in.
  double get crossAxisPadding {
    assert(resolvedPadding != null);
    return switch (constraints.axis) {
      Axis.horizontal => resolvedPadding!.vertical,
      Axis.vertical => resolvedPadding!.horizontal,
    };
  }

  void _resolve() {
    if (resolvedPadding != null) {
      return;
    }
    _resolvedPadding = padding.resolve(textDirection);
    assert(resolvedPadding!.isNonNegative);
  }

  void _markNeedsResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;
  set padding(EdgeInsetsGeometry value) {
    assert(padding.isNonNegative);
    if (_padding == value) {
      return;
    }
    _padding = value;
    _markNeedsResolution();
  }

  /// The text direction with which to resolve [padding].
  ///
  /// This may be changed to null, but only after the [padding] has been changed
  /// to a value that does not depend on the direction.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    _markNeedsResolution();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void performLayout() {
    _resolve();
    final SliverConstraints constraints = this.constraints;
    double paintOffset({required double from, required double to}) =>
        calculatePaintOffset(constraints, from: from, to: to);
    double cacheOffset({required double from, required double to}) =>
        calculateCacheOffset(constraints, from: from, to: to);

    assert(this.resolvedPadding != null);
    final EdgeInsets resolvedPadding = this.resolvedPadding!;
    final double beforePadding = this.beforePadding;
    final double afterPadding = this.afterPadding;
    final double mainAxisPadding = this.mainAxisPadding;
    final double crossAxisPadding = this.crossAxisPadding;
    if (child == null) {
      final double paintExtent = paintOffset(from: 0.0, to: mainAxisPadding);
      final double cacheExtent = cacheOffset(from: 0.0, to: mainAxisPadding);
      geometry = SliverGeometry(
        scrollExtent: mainAxisPadding,
        paintExtent: math.min(paintExtent, constraints.remainingPaintExtent),
        maxPaintExtent: mainAxisPadding,
        cacheExtent: cacheExtent,
      );
      return;
    }
    final double beforePaddingPaintExtent = paintOffset(from: 0.0, to: beforePadding);
    double overlap = constraints.overlap;
    if (overlap > 0) {
      overlap = math.max(0.0, constraints.overlap - beforePaddingPaintExtent);
    }
    child!.layout(
      constraints.copyWith(
        scrollOffset: math.max(0.0, constraints.scrollOffset - beforePadding),
        cacheOrigin: math.min(0.0, constraints.cacheOrigin + beforePadding),
        overlap: overlap,
        remainingPaintExtent:
            constraints.remainingPaintExtent - paintOffset(from: 0.0, to: beforePadding),
        remainingCacheExtent:
            constraints.remainingCacheExtent - cacheOffset(from: 0.0, to: beforePadding),
        crossAxisExtent: math.max(0.0, constraints.crossAxisExtent - crossAxisPadding),
        precedingScrollExtent: beforePadding + constraints.precedingScrollExtent,
      ),
      parentUsesSize: true,
    );
    final SliverGeometry childLayoutGeometry = child!.geometry!;
    if (childLayoutGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(scrollOffsetCorrection: childLayoutGeometry.scrollOffsetCorrection);
      return;
    }
    final double scrollExtent = childLayoutGeometry.scrollExtent;
    final double beforePaddingCacheExtent = cacheOffset(from: 0.0, to: beforePadding);
    final double afterPaddingCacheExtent = cacheOffset(
      from: beforePadding + scrollExtent,
      to: mainAxisPadding + scrollExtent,
    );
    final double afterPaddingPaintExtent = paintOffset(
      from: beforePadding + scrollExtent,
      to: mainAxisPadding + scrollExtent,
    );
    final double mainAxisPaddingCacheExtent = beforePaddingCacheExtent + afterPaddingCacheExtent;
    final double mainAxisPaddingPaintExtent = beforePaddingPaintExtent + afterPaddingPaintExtent;
    final double paintExtent = math.min(
      beforePaddingPaintExtent +
          math.max(
            childLayoutGeometry.paintExtent,
            childLayoutGeometry.layoutExtent + afterPaddingPaintExtent,
          ),
      constraints.remainingPaintExtent,
    );
    final double? crossAxisExtent = childLayoutGeometry.crossAxisExtent;
    geometry = SliverGeometry(
      paintOrigin: childLayoutGeometry.paintOrigin,
      scrollExtent: mainAxisPadding + scrollExtent,
      paintExtent: paintExtent,
      layoutExtent: math.min(
        mainAxisPaddingPaintExtent + childLayoutGeometry.layoutExtent,
        paintExtent,
      ),
      cacheExtent: math.min(
        mainAxisPaddingCacheExtent + childLayoutGeometry.cacheExtent,
        constraints.remainingCacheExtent,
      ),
      maxPaintExtent: mainAxisPadding + childLayoutGeometry.maxPaintExtent,
      crossAxisExtent: crossAxisExtent != null && crossAxisExtent.isFinite
          ? crossAxisExtent + crossAxisPadding
          : crossAxisExtent,
      hitTestExtent: math.max(
        mainAxisPaddingPaintExtent + childLayoutGeometry.paintExtent,
        beforePaddingPaintExtent + childLayoutGeometry.hitTestExtent,
      ),
      hasVisualOverflow: childLayoutGeometry.hasVisualOverflow,
    );
    final double calculatedOffset = switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      HorizontalAxisDirection.left => paintOffset(
        from: resolvedPadding.right + scrollExtent,
        to: resolvedPadding.horizontal + scrollExtent,
      ),
      HorizontalAxisDirection.right => paintOffset(from: 0.0, to: resolvedPadding.left),
    };
    final SliverPhysicalParentData childParentData = child!.parentData! as SliverPhysicalParentData;
    childParentData.paintOffset = switch (constraints.axis) {
      Axis.horizontal => Offset(calculatedOffset, resolvedPadding.top),
      Axis.vertical => Offset(resolvedPadding.left, calculatedOffset),
    };
    assert(beforePadding == this.beforePadding);
    assert(afterPadding == this.afterPadding);
    assert(mainAxisPadding == this.mainAxisPadding);
    assert(crossAxisPadding == this.crossAxisPadding);
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (child != null && child!.geometry!.hitTestExtent > 0.0) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      return result.addWithAxisOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
        mainAxisOffset: childMainAxisPosition(child!),
        crossAxisOffset: childCrossAxisPosition(child!),
        paintOffset: childParentData.paintOffset,
        hitTest: child!.hitTest,
      );
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderSliver child) {
    assert(child == this.child);
    return calculatePaintOffset(constraints, from: 0.0, to: beforePadding);
  }

  @override
  double childCrossAxisPosition(RenderSliver child) {
    assert(child == this.child);
    assert(resolvedPadding != null);
    return switch (constraints.axis) {
      Axis.horizontal => resolvedPadding!.top,
      Axis.vertical => resolvedPadding!.left,
    };
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    return beforePadding;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child == this.child);
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    super.debugPaint(context, offset);
    assert(() {
      if (debugPaintSizeEnabled) {
        final Size parentSize = getAbsoluteSize();
        final Rect outerRect = offset & parentSize;
        Rect? innerRect;
        if (child != null) {
          final Size childSize = child!.getAbsoluteSize();
          final SliverPhysicalParentData childParentData =
              child!.parentData! as SliverPhysicalParentData;
          innerRect = (offset + childParentData.paintOffset) & childSize;
          assert(innerRect.top >= outerRect.top);
          assert(innerRect.left >= outerRect.left);
          assert(innerRect.right <= outerRect.right);
          assert(innerRect.bottom <= outerRect.bottom);
        }
        debugPaintPadding(context.canvas, outerRect, innerRect);
      }
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }
}
