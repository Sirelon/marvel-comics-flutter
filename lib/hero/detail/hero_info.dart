import 'package:flutter/material.dart';
import 'package:marvel_heroes/hero/detail/detail.dart';
import 'package:marvel_heroes/hero/detail/widgets.dart';
import 'package:marvel_heroes/router.dart';
import 'package:marvel_heroes/widgets/BlurredWidget.dart';

class DetailHeroInfo extends StatelessWidget {
  const DetailHeroInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HeroPageState state = HeroDetailPage.of(context);
    final queryData = MediaQuery.of(context);

    var titleColor = state.dominantColor;

    var padding = state.padding;
    var titleStyle = TextStyle(
        fontFamily: 'Black',
        color: titleColor,
        fontWeight: FontWeight.w900,
        letterSpacing: padding,
        fontSize: 36 * queryData.textScaleFactor);

    var edgeInsets = EdgeInsets.all(padding);

    return BlurredWidget(
        imageProvider: state.imageProvider,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 18),
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
                    fontSize: 24 * queryData.textScaleFactor,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                )),
            ExpandButton(2)
          ],
        ));
  }
}
