import 'dart:math' show Random;
import 'dart:ui' show clampDouble;

import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.data);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        data,
        style: TextTheme.of(context).titleMedium?.copyWith(
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class SectionDescription extends StatelessWidget {
  const SectionDescription(this.data, {this.semiBold = false});

  final String data;
  final bool semiBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        data,
        style: !semiBold
            ? null
            : TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class RandomColoredCardImage extends StatelessWidget {
  const RandomColoredCardImage(this.random);

  final Random random;

  static const List<Color> colors = [
    Color(0xFFEEEEEE),
    Color(0xFFD96B8A),
    Color(0xFFE0E0E0),
    Color(0xFFA7F09B),
    Color(0xFFAE4EAE),
    Color(0xFFA3A355),
    Color(0xFFA0C4FF),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        color: colors[random.nextInt(colors.length)],
      ),
    );
  }
}

class RandomCardTitleLines extends StatelessWidget {
  const RandomCardTitleLines(this.random);

  final Random random;

  @override
  Widget build(BuildContext context) {
    final int titleLineCount = random.nextInt(2) + 1; // >= 1 and <= 2

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        titleLineCount,
        (index) {
          double widthFactor;
          if (index == 0) {
            widthFactor = 1.0;
          } else {
            widthFactor = clampDouble(random.nextDouble(), 0.3, 1.0);
          }

          return FractionallySizedBox(
            widthFactor: widthFactor,
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 4, 4),
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
                color: const Color(0xFFEFEFEF),
              ),
            ),
          );
        },
      ),
    );
  }
}

List<Widget> buildRandomCardDescriptionLines(
  Random random, {
  required int cardIndex,
}) {
  final List<double> widths = [ 0.5, 0.3, 0.7, 0.8, 0.6 ];
  final int descriptionLineCount = cardIndex < 4
      ? random.nextBool()
          ? 0 : 2
      : random.nextInt(5); // >= 0 and <= 5

  return List.generate(
    descriptionLineCount,
    (index) {
      double widthFactor;
      if (index == 0 && descriptionLineCount > 1) {
        widthFactor = 1.0;
      } else {
        widthFactor = widths.removeAt(random.nextInt(widths.length));
      }

      return FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          margin: EdgeInsets.fromLTRB(3, 0, 4, 4),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(2),
            ),
            color: const Color(0xFF37F6ED),
          ),
        ),
      );
    },
  );
}
