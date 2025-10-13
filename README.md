# horizontal_list_view

[![Version](https://img.shields.io/pub/v/horizontal_list_view?include_prereleases)](https://pub.dartlang.org/packages/horizontal_list_view)
[![Pub Points](https://img.shields.io/pub/points/horizontal_list_view)](https://pub.dev/packages/horizontal_list_view/score)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A horizontal ListView that doesn't require a fixed height.

## Features

The `HorizontalListView` widget is designed as a replacement to the Flutter [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html) with `scrollDirection: Axis.horizontal`.

Each child in the `HorizontalListView` is being laid out without any constraints, allowing them to determine their "natural" size. This means that the height of the `HorizontalListView` adjusts to the tallest currently laid out child.

You can also wrap `HorizontalListView` with a bounded the height (e.g. using a [SizedBox](https://api.flutter.dev/flutter/widgets/SizedBox-class.html)) to limit the maximum height of its children.

By setting the `flexibleHeight` property to `true`, the height of the `HorizontalListView` will dynamically adjust to match the height of the currently visible laid out child.

### Limitation

* Using [Center](https://api.flutter.dev/flutter/widgets/Center-class.html) and [Align](https://api.flutter.dev/flutter/widgets/Align-class.html) requires bounded height

Since children can be laid out without any constraints, widgets like [Center](https://api.flutter.dev/flutter/widgets/Center-class.html) or [Align](https://api.flutter.dev/flutter/widgets/Align-class.html) will not expand to fill the height of the `HorizontalListView`. These widgets size themselves based on their child when no height constraint is provided.

If you want them to fill the height, make sure the `HorizontalListView` has a bounded height, using something like a [SizedBox](https://api.flutter.dev/flutter/widgets/SizedBox-class.html).

* No `itemExtent` or `itemExtentBuilder` properties

Because each child must be laid out individually to determine its height, the `itemExtent` and `itemExtentBuilder` properties are not supported.

## Usage

Like [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html), there are four options for constructing a `HorizontalListView`:

1. The default constructor takes an explicit `List<Widget>` of children. This constructor is appropriate for list views with a small number of children because constructing the List requires doing work for every child that could possibly be displayed in the list view instead of just those children that are actually visible.

2. The `HorizontalListView.builder` constructor takes an [IndexedWidgetBuilder](https://api.flutter.dev/flutter/widgets/IndexedWidgetBuilder.html), which builds the children on demand. This constructor is appropriate for list views with a large (or infinite) number of children because the builder is called only for those children that are actually visible.

3. The `HorizontalListView.separated` constructor takes two [IndexedWidgetBuilder](https://api.flutter.dev/flutter/widgets/IndexedWidgetBuilder.html)s: `itemBuilder` builds child items on demand, and `separatorBuilder` similarly builds separator children which appear in between the child items. This constructor is appropriate for list views with a fixed number of children.

4. The `HorizontalListView.custom` constructor takes a [SliverChildDelegate](https://api.flutter.dev/flutter/widgets/SliverChildDelegate-class.html), which provides the ability to customize additional aspects of the child model. For example, a [SliverChildDelegate](https://api.flutter.dev/flutter/widgets/SliverChildDelegate-class.html) can control the algorithm used to estimate the size of children that are not actually visible.

To control the initial scroll offset of the scroll view, provide a [controller](https://api.flutter.dev/flutter/widgets/ScrollView/controller.html) with its [ScrollController.initialScrollOffset](https://api.flutter.dev/flutter/widgets/ScrollController/initialScrollOffset.html) property set.

By default, `HorizontalListView` will automatically pad the list's scrollable extremities to avoid partial obstructions indicated by [MediaQuery](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)'s padding. To avoid this behavior, override with a zero [padding](https://pub.dev/documentation/horizontal_list_view/latest/horizontal_list_view/HorizontalListView/padding.html) property.

If non-null, the [prototypeItem](https://pub.dev/documentation/horizontal_list_view/latest/horizontal_list_view/HorizontalListView/prototypeItem.html) forces the children to have the same size as the given widget in the scroll direction.

Specifying an [prototypeItem](https://pub.dev/documentation/horizontal_list_view/latest/horizontal_list_view/HorizontalListView/prototypeItem.html) is more efficient than letting the children determine their own size because the scrolling machinery can make use of the foreknowledge of the children's size to save work, for example when the scroll position changes drastically.

This example uses the default constructor for `HorizontalListView` which takes an explicit `List<Widget>` of children. This `HorizontalListView`'s children are made up of [Container](https://api.flutter.dev/flutter/widgets/Container-class.html)s with [Text](https://api.flutter.dev/flutter/widgets/Text-class.html).

![](https://github.com/thanhle1547/flutter_flexible_horizontal_list_view/blob/main/screenshots/default_constructor.gif)

```dart
HorizontalListView(
  padding: const EdgeInsets.all(8),
  children: <Widget>[
    Container(
      width: 200,
      color: Colors.amber.shade400,
      child: Text(
        '  Entry A  ',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    Container(
      width: 300,
      color: Colors.amber.shade500,
      child: Text(
        '  Entry B  ',
        style: TextStyle(fontSize: 30),
      ),
    ),
    Container(
      width: 200,
      color: Colors.amber.shade600,
      child: Text(
        '  Entry C  ',
        style: TextStyle(fontSize: 10),
      ),
    ),
    Container(
      width: 350,
      color: Colors.amber.shade700,
      child: Text(
        '  Entry D  ',
        style: TextStyle(fontSize: 50),
      ),
    ),
  ],
)
```

This example mirrors the previous one, creating the same list using the `HorizontalListView.builder` constructor. Using the [IndexedWidgetBuilder](https://api.flutter.dev/flutter/widgets/IndexedWidgetBuilder.html), children are built lazily and can be infinite in number.

```dart
final List<String> entries = <String>['A', 'B', 'C', 'D'];
final List<int> colorCodes = <int>[400, 500, 600, 700];
final List<double> widths = <double>[200.0, 300.0, 200.0, 350.0];
final List<double> fontSizes = <double>[20.0, 30.0, 10.0, 50.0];

Widget build(BuildContext context) {
  return HorizontalListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: entries.length,
    itemBuilder: (context, index) {
      return Container(
        width: widths[index],
        color: Colors.amber[colorCodes[index]],
        child: Text(
          '  Entry ${entries[index]}  ',
          style: TextStyle(fontSize: fontSizes[index], fontWeight: FontWeight.bold),
        ),
      );
    },
  );
}
```

This example continues to build from our the previous ones, creating a similar list using `HorizontalListView.separated`. Here, a [SizedBox](https://api.flutter.dev/flutter/widgets/SizedBox-class.html) is used as a separator.

![](https://github.com/thanhle1547/flutter_flexible_horizontal_list_view/blob/main/screenshots/seperated_constructor.gif)

```dart
final List<String> entries = <String>['A', 'B', 'C', 'D'];
final List<int> colorCodes = <int>[400, 500, 600, 700];
final List<double> widths = <double>[200.0, 300.0, 200.0, 350.0];
final List<double> fontSizes = <double>[20.0, 30.0, 10.0, 50.0];

Widget build(BuildContext context) {
  return HorizontalListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: entries.length,
    itemBuilder: (context, index) {
      return Container(
        width: widths[index],
        color: Colors.amber[colorCodes[index]],
        child: Text(
          '  Entry ${entries[index]}  ',
          style: TextStyle(fontSize: fontSizes[index], fontWeight: FontWeight.bold),
        ),
      );
    },
    separatorBuilder: (context, index) => SizedBox(width: 10),
  );
}
```
