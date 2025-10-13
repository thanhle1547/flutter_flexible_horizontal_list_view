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
        child: HorizontalListView(
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
        ),
      ),
    );
  }
}
