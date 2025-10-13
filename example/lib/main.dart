import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizontal_list_view/horizontal_list_view.dart';

import 'widgets.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'horizontal_list_view Package Demo',
      debugShowCheckedModeBanner: false,
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage();

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final Random random = Random();

  bool flexibleHeight = false;

  @override
  Widget build(BuildContext context) {
    const Widget gap = SizedBox(height: 10);
    const Widget bigGap = SizedBox(height: 20);
    const Widget divider = Divider(height: 0, thickness: 0);

    const EdgeInsets listViewPadding = EdgeInsets.symmetric(horizontal: 16);

    final double screenWidth = MediaQuery.widthOf(context);
    final double cardItemWidth = screenWidth * 0.65;

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'horizontal_list_view',
                style: TextStyle(fontFamily: 'monospace', fontSize: 20),
              ),
              TextSpan(text: ' Demo'),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Restart',
            icon: Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SingleChildScrollView(
        key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            divider,
            SwitchListTile(
              title: Text('Shrink-wrapping cross axis'),
              value: flexibleHeight,
              onChanged: (value) {
                setState(() {
                  flexibleHeight = !flexibleHeight;
                });
              },
            ),
            divider,

            bigGap,

            SectionTitle('HorizontalListView()'),
            gap,
            HorizontalListView(
              padding: listViewPadding,
              flexibleHeight: flexibleHeight,
              children: List.generate(
                8,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: cardItemWidth,
                    child: CardItem(
                      index: index,
                      random: random,
                    ),
                  ),
                ),
              ),
            ),

            bigGap,
            divider,
            bigGap,

            SectionTitle('HorizontalListView.builder()'),
            gap,
            HorizontalListView.builder(
              padding: listViewPadding,
              flexibleHeight: flexibleHeight,
              itemCount: 8,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: cardItemWidth,
                    child: CardItem(
                      index: index,
                      random: random,
                    ),
                  ),
                );
              },
            ),

            bigGap,
            divider,
            bigGap,

            SectionTitle('HorizontalListView.separated()'),
            gap,
            HorizontalListView.separated(
              padding: listViewPadding,
              flexibleHeight: flexibleHeight,
              separatorBuilder: (context, index) => SizedBox(width: 10),
              itemCount: 8,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: cardItemWidth,
                  child: CardItem(
                    index: index,
                    random: random,
                  ),
                );
              },
            ),

            bigGap,
            divider,
            bigGap,

            SectionTitle('HorizontalListView(\n  prototypeItem != null  \n)'),
            gap,
            HorizontalListView.builder(
              clipBehavior: Clip.none,
              padding: listViewPadding,
              prototypeItem: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ImageCard(index: 0),
              ),
              itemCount: ImageCard.cardTitles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ImageCard(index: index),
                );
              },
            ),
            gap,
            SectionDescription(
              'The [prototypeItem] property forces children\'s size to be the same as '
              'the given widget. Using a prototype is more efficient than letting children '
              'determine their own size, and it also simplifies handling the platform\'s text '
              'scale factor changes.',
            ),

            bigGap,
            divider,
            bigGap,

            SectionTitle('''SizedBox(
  height: 120,
  child: ListView.builder(
    prototypeItem != null
  )
)'''),
            gap,
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: listViewPadding,
                prototypeItem: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ImageCard(index: 0),
                ),
                itemCount: ImageCard.cardTitles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: ImageCard(index: index),
                  );
                },
              ),
            ),
            gap,
            SectionDescription(
              'The [prototypeItem] property of the [ListView] only forces the children '
              'to have the same width as the given widget and '
              'requires the [ListView] to be given a bounded height constraint. '
              'Furthermore, when the platform\'s text scale factor changes, '
              'recalculation is necessary to prevent overflow.'
            ),
            SectionDescription(
              'Note: To observe this issue, change the platform\'s text scale factor in system preferences.',
              semiBold: true,
            ),

            bigGap,
            divider,
            bigGap,

            bigGap,
            bigGap,
            bigGap,
            bigGap,
          ],
        ),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  const CardItem({
    required this.index,
    required this.random,
  });

  final int index;
  final Random random;

  @override
  Widget build(BuildContext context) {
    final Widget image = RandomColoredCardImage(random);
    final Widget title = RandomCardTitleLines(random);
    final List<Widget> description = buildRandomCardDescriptionLines(
      random,
      cardIndex: index,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        image,
        SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                index.toString(),
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: title,
            ),
          ],
        ),
        SizedBox(height: 4),
        ...description,
      ],
    );
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard({required this.index});

  final int index;

  static const List<String> cardTitles = [
    'The Flow',
    'Through the Pane',
    'Iridescence',
    'Sea Change',
    'Blue Symphony',
    'When It Rains',
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: <Widget>[
        SizedBox(
          width: width * 7 / 8,
          height: 120,
          child: Image(
            fit: BoxFit.cover,
            image: AssetImage(
              "assets/content_based_color_scheme_${index + 1}.png",
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                cardTitles[index],
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Sponsored | Season 1 Now Streaming',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
