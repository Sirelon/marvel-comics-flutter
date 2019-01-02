import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/SensitiveWidget.dart';

class HeroDetailPage extends StatefulWidget {
  final MarvelHero hero;

  const HeroDetailPage({Key key, this.hero}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HeroDetailPageState();
}

class _HeroDetailPageState extends State<HeroDetailPage> {
  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;
    final bg = CachedNetworkImage(
        errorWidget: Icon(Icons.error),
        imageUrl: hero.image,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        placeholder: CircularProgressIndicator());

    var blackStyle = TextStyle(
        fontFamily: 'Black',
        color: Colors.white,
        fontWeight: FontWeight.normal,
        letterSpacing: 8.0,
        fontSize: 36.0);

    return new Scaffold(
        appBar: AppBar(title: Text(widget.hero.name)),
        body: new Stack(children: <Widget>[
          SensitiveWidget(child: bg),
          Center(
            child: Text(
              hero.name,
              style: blackStyle,
              textAlign: TextAlign.center,
            ),
          )
        ]));
  }
}
