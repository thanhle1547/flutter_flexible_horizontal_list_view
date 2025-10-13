import 'package:flutter/material.dart';
import 'package:flexible_horizontal_list_view/flexible_horizontal_list_view.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flexible_horizontal_list_view Package Demo',
      debugShowCheckedModeBanner: false,
      home: const DemoPage(),
    );
  }
}

final List<String> entries = <String>['A', 'B', 'C', 'D'];
final List<int> colorCodes = <int>[400, 500, 600, 700];
final List<double> widths = <double>[200.0, 300.0, 200.0, 350.0];
final List<double> fontSizes = <double>[20.0, 30.0, 10.0, 50.0];

class DemoPage extends StatelessWidget {
  const DemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Default constructor'),
      ),
      body: ColoredBox(
        color: Colors.teal,
        child: HorizontalListView.builder(
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
        ),
      ),
    );
  }
}
