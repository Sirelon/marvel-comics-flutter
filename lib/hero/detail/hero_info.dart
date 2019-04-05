import 'package:flutter/material.dart';
import 'package:marvel_heroes/hero/detail/detail.dart';
import 'package:marvel_heroes/hero/detail/widgets.dart';
import 'package:marvel_heroes/router.dart';

class DetailHeroInfo extends StatelessWidget {
  const DetailHeroInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HeroPageState state = HeroDetailPage.of(context);

    var titleColor = state.dominantColor;

    var padding = state.padding;
    var titleStyle = TextStyle(
        fontFamily: 'Black',
        color: titleColor,
        fontWeight: FontWeight.w900,
        letterSpacing: padding * 2,
        fontSize: 56.0);

    var edgeInsets = EdgeInsets.all(padding);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
            onPressed: () =>
                Router(context).launchURL(state.hero.urlHolder.detailUrl),
            padding: edgeInsets,
            child: Text(
              state.hero.name,
              style: titleStyle,
              textAlign: TextAlign.center,
            )),
        Padding(
            padding: edgeInsets,
            child: Text(
              '     ${state.hero.description}',
              style: TextStyle(
                fontSize: 20.0,
                color: titleColor,
              ),
              textAlign: TextAlign.start,
            )),
        ExpandButton(2)
      ],
    );
  }
}
