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
    return new Scaffold(
        appBar: AppBar(title: Text(widget.hero.name)),
        body: new Stack(children: <Widget>[
          SensitiveWidget(
              child: CachedNetworkImage(
                  errorWidget: Icon(Icons.error),
                  imageUrl: hero.image,
                  placeholder: CircularProgressIndicator()))
        ]));
  }
}
