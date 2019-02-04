import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/SensitiveWidget.dart';
import 'package:marvel_heroes/network.dart';
import 'package:marvel_heroes/router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:random_color/random_color.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HeroDetailPage extends StatefulWidget {
  final MarvelHero hero;

  const HeroDetailPage({Key key, this.hero}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HeroDetailPageState();
}

class _HeroDetailPageState extends State<HeroDetailPage> {
  ImageProvider imageProvider;

  Color dominantColor = Colors.white;
  Color invertColor = Colors.white;
  Brightness brightness = Brightness.dark;

  RandomColor _randomColor = RandomColor();
  PageController pageController = PageController();

  @override
  void initState() {
    imageProvider = CachedNetworkImageProvider(widget.hero.image);
    _updatePaletteGenerator();
    super.initState();
  }

  void _updatePaletteGenerator() {
    PaletteGenerator.fromImageProvider(imageProvider).then((paletteGenerator) {
      setState(() {
        dominantColor = paletteGenerator?.dominantColor?.color;
        if (dominantColor == null) {
          dominantColor =
              _randomColor.randomColor(colorBrightness: ColorBrightness.light);
        }
        brightness = ThemeData.estimateBrightnessForColor(dominantColor);
        if (brightness == Brightness.dark) {
          invertColor = Colors.white;
        } else {
          invertColor = Colors.black;
        }

        print('Dominant color $dominantColor ');
      });
    }, onError: (e) => debugPrint(e));
  }

  static HSLColor fromHsl(HSLColor passedColor) {
    num newH = passedColor.hue + 180;
    if (newH > 360) newH -= 360;
    HSLColor newHslColor = new HSLColor.fromAHSL(
        1, newH, passedColor.saturation, passedColor.lightness);
    return newHslColor;
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;

    final bg = Image(
        image: imageProvider,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center);

    final iconAppBarTheme = IconThemeData(color: invertColor);

    var titleStyle = TextStyle(
        fontFamily: 'Black',
        color: invertColor,
        letterSpacing: 8.0,
        fontSize: 16.0);

    return new Scaffold(
        appBar: AppBar(
          title: Text(
            widget.hero.name,
            style: TextStyle(color: invertColor),
          ),
          backgroundColor: dominantColor,
          brightness: brightness,
          iconTheme: iconAppBarTheme,
        ),
        body: PageView(
          controller: pageController,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Stack(children: <Widget>[
              SensitiveWidget(child: bg),
              SafeArea(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FlatButton.icon(
                        onPressed: () {
                          pageController.animateToPage(1,
                              duration: Duration(seconds: 1),
                              curve: Curves.ease);
                        },
                        icon: Icon(Icons.keyboard_arrow_down),
                        label: Text(
                          "Expand",
                          style: titleStyle,
                        ),
                      )))
            ]),
            DetailHeroInfo(
              hero: hero,
              titleColor: dominantColor,
            )
          ],
        ));
  }
}

class DetailHeroInfo extends StatelessWidget {
  const DetailHeroInfo(
      {Key key, @required this.hero, @required this.titleColor})
      : super(key: key);

  final MarvelHero hero;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    var padding = 8.0;
    var titleStyle = TextStyle(
        fontFamily: 'Black',
        color: titleColor,
        fontWeight: FontWeight.w800,
        letterSpacing: padding,
        fontSize: 36.0);
    var subTitleStyle = TextStyle(
      fontSize: 20.0,
      color: titleColor,
    );

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        FlatButton(
            onPressed: () {},
            padding: EdgeInsets.all(8.0),
            child: Text(
              hero.name,
              style: titleStyle,
              textAlign: TextAlign.center,
            )),
        SizedBox(height: padding),
        Padding(
            padding: EdgeInsets.all(padding),
            child: Text(
              '     ${hero.description}',
              style: subTitleStyle,
              textAlign: TextAlign.start,
            )),
        SizedBox(height: padding),
        FutureBuilder<List<MarvelComics>>(
            future: fetchComicsByHero(hero),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator());
                default:
                  return ComicsListWidget(data: snapshot.data);
              }
            })
      ],
    ));
  }
}

class ComicsListWidget extends StatelessWidget {
  final List<MarvelComics> data;

  const ComicsListWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return RaisedButton(
        onPressed: () {
          Router(context).closeCurrent();
        },
        child: Text("Back"),
      );
    }
    final List<Widget> comicsImageList =
        data.map((comics) => _buildCarouselItem(comics, context)).toList();

    return Expanded(
        child: CarouselSlider(
            items: comicsImageList,
            aspectRatio: 3 / 4,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlay: true,
            viewportFraction: 0.75));
  }

  Widget _buildCarouselItem(MarvelComics comics, BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: ClipRRect(
            borderRadius: new BorderRadius.circular(16.0),
            child: Stack(children: <Widget>[
              Column(children: <Widget>[
                CachedNetworkImage(imageUrl: comics.image, fit: BoxFit.cover),
                Text(
                  comics.title,
                  style: Theme.of(context).primaryTextTheme.headline,
                )
              ]),
              new Material(
                  color: Colors.transparent, child: InkWell(onTap: () {}))
            ])));
  }
}
