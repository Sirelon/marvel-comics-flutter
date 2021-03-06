import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:marvel_heroes/hero/detail/detail.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/network.dart';
import 'package:marvel_heroes/router.dart';
import 'package:marvel_heroes/widgets/loading_widgets.dart';

class HeroComicsPage extends StatelessWidget {
  Future<List<MarvelComics>> _comicsFuture;

  @override
  Widget build(BuildContext context) {
    final HeroPageState state = HeroDetailPage.of(context);

    if (_comicsFuture == null) {
      _comicsFuture = fetchComicsByHero(state.hero);
    }

    return FutureBuilder<List<MarvelComics>>(
        future: _comicsFuture,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: BigLoadingWidget());
            default:
              return _ComicsListWidget(data: snapshot.data);
          }
        });
  }
}

class _ComicsListWidget extends StatelessWidget {
  final List<MarvelComics> data;

  const _ComicsListWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return RaisedButton(
        onPressed: () => Router(context).closeCurrent(),
        child: Text("Back"),
      );
    }

    final HeroPageState state = HeroDetailPage.of(context);
    TextStyle titleStyle = TextStyle(
        color: state.dominantColor,
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        fontFamily: 'Marvel');

    final List<Widget> comicsImageList = data
        .map((comics) => _buildCarouselItem(context, comics, titleStyle))
        .toList();

    final queryData = MediaQuery.of(context);

    final ratio = queryData.size.aspectRatio;

    final fraction = (ratio < 1) ? 0.65 : 0.35;

    print(ratio);

    return CarouselSlider(
      items: comicsImageList,
      aspectRatio: ratio,
      height: queryData.size.height - 150,
      autoPlayCurve: Curves.fastOutSlowIn,
      autoPlay: true,
      viewportFraction: fraction,
    );
  }

  Widget _buildCarouselItem(
      BuildContext context, MarvelComics comics, TextStyle titleStyle) {
    return Padding(
        padding: EdgeInsets.all(4.0),
        child: ClipRRect(
            borderRadius: new BorderRadius.circular(16.0),
            child: Stack(children: <Widget>[
              Column(children: <Widget>[
                CachedNetworkImage(
                    imageUrl: comics.image,
                    fit: BoxFit.scaleDown,
                    placeholder: SmallLoadingWidget()),
                Text(
                  comics.title,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                )
              ]),
              new Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: () => _onComicsClick(context, comics)))
            ])));
  }

  _onComicsClick(BuildContext context, MarvelComics comics) {
    Router(context).launchURL(comics.url);
  }
}
