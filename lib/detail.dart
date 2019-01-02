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
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        placeholder: CircularProgressIndicator());

    return new Scaffold(
        appBar: AppBar(title: Text(widget.hero.name)),
        body: new Stack(children: <Widget>[
          SensitiveWidget(child: bg),
          SafeArea(child: DetailHeroInfo(hero: hero))
        ]));
  }
}

class DetailHeroInfo extends StatelessWidget {
  const DetailHeroInfo({
    Key key,
    @required this.hero,
  }) : super(key: key);

  final MarvelHero hero;

  @override
  Widget build(BuildContext context) {
    var padding = 8.0;
    var blackStyle = TextStyle(
        fontFamily: 'Black',
        color: Colors.white,
        fontWeight: FontWeight.normal,
        letterSpacing: padding,
        fontSize: 42.0);

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          hero.name,
          style: blackStyle,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: padding,
        ),
        Padding(
            padding: EdgeInsets.all(padding),
            child: Text(
              '     ${hero.description}',
              style: Theme.of(context).primaryTextTheme.title,
              textAlign: TextAlign.start,
            )),
      ],
    ));
  }
}
