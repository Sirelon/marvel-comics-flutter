import 'package:flutter/material.dart';
import 'package:marvel_heroes/hero/detail/detail.dart';
import 'package:marvel_heroes/router.dart';

class DetailHeroInfo extends StatelessWidget {
  const DetailHeroInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HeroPageState state = HeroDetailPage.of(context);

    var titleColor = state.dominantColor;

    var titleStyle = TextStyle(
        fontFamily: 'Black',
        color: titleColor,
        fontWeight: FontWeight.w800,
        letterSpacing: state.padding,
        fontSize: 36.0);

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        FlatButton(
            onPressed: () {
              Router(context).launchURL(state.hero.urlHolder.detailUrl);
            },
            padding: EdgeInsets.all(8.0),
            child: Text(
              state.hero.name,
              style: titleStyle,
              textAlign: TextAlign.center,
            )),
//        SizedBox(height: padding),
//        Padding(
//            padding: EdgeInsets.all(padding),
//            child: Text(
//              '     ${hero.description}',
//              style: subTitleStyle,
//              textAlign: TextAlign.start,
//            )),
//        SizedBox(height: padding),
      ],
    ));
  }
}
