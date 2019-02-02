import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/SensitiveWidget.dart';
import 'package:marvel_heroes/network.dart';
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

  PaletteGenerator paletteGenerator;
  Color dominantColor = Colors.white;
  Color invertColor = Colors.white;
  RandomColor _randomColor = RandomColor();
  PageController pageController = PageController();

  @override
  void initState() {
    imageProvider = CachedNetworkImageProvider(widget.hero.image);
    _updatePaletteGenerator();
    super.initState();
  }

  void _updatePaletteGenerator() {
    PaletteGenerator.fromImageProvider(imageProvider).then((value) {
      setState(() {
        paletteGenerator = value;
        dominantColor = paletteGenerator?.dominantColor?.color;
        if (dominantColor == null) {
          dominantColor =
              _randomColor.randomColor(colorBrightness: ColorBrightness.light);
        }
        print('Dominant color $dominantColor ');
//        print('Dominant color ' + dominantColor.toString());
        final hslColor = HSLColor.fromColor(dominantColor);
        invertColor = fromHsl(hslColor).toColor();
//        invertColor = Color.fromARGB(
//            dominantColor.alpha,
//            (0.2126 * dominantColor.red).toInt(),
//            (0.7152 * dominantColor.green).toInt(),
//            (0.0722 * dominantColor.blue).toInt());
//            255 - dominantColor.green,
//            255 - dominantColor.blue);
//        print('Invert color ' + invertColor.toString());
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
//    final bg = CachedNetworkImage(
//        errorWidget: Icon(Icons.error),
//        imageUrl: hero.image,
//        fit: BoxFit.cover,
//        height: double.infinity,
//        width: double.infinity,
//        alignment: Alignment.center,
//        placeholder: CircularProgressIndicator());

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
        fontWeight: FontWeight.w800,
        letterSpacing: 8.0,
        fontSize: 42.0);

    return new Scaffold(
        appBar: AppBar(
          title: Text(
            widget.hero.name,
            style: TextStyle(color: invertColor),
          ),
          backgroundColor: dominantColor,
          brightness: ThemeData.estimateBrightnessForColor(dominantColor),
          iconTheme: iconAppBarTheme,
        ),
        body: PageView(
          controller: pageController,
//          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Stack(children: <Widget>[
              SensitiveWidget(child: bg),
              SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: EdgeInsets.all(24.0),
                      alignment: Alignment.topCenter,
                      child: Text(
                        hero.name,
                        style: titleStyle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      )),
                  FlatButton.icon(
                      onPressed: () {
                        pageController.animateToPage(1,
                            duration: Duration(seconds: 1), curve: Curves.ease);
                      },
                      icon: Icon(Icons.keyboard_arrow_down),
                      label: Text("Expand"))
                ],
              ))
            ]),
            DetailHeroInfo(
              hero: hero,
              titleColor: invertColor,
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
        fontSize: 42.0);
    var subTitleStyle = TextStyle(
      fontSize: 24.0,
      color: titleColor,
    );

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          hero.name,
          style: titleStyle,
          textAlign: TextAlign.center,
        ),
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
                  return Expanded(child: ComicsListWidget(data: snapshot.data));
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
    final List<Widget> comicsImageList =
        data.map((comics) => _buildCarouselItem(comics)).toList();

    return CarouselSlider(
        items: comicsImageList,
        aspectRatio: 3 / 4,
        autoPlayCurve: Curves.fastOutSlowIn,
        autoPlay: true,
        viewportFraction: 0.8);
  }

  Widget _buildCarouselItem(MarvelComics comics) {
    return ClipRRect(
        borderRadius: new BorderRadius.circular(16.0),
        child: Stack(
          children: <Widget>[
            Image.network(comics.image, fit: BoxFit.cover),
            new Material(
                color: Colors.transparent, child: InkWell(onTap: () {})),
          ],
        ));
  }
}
