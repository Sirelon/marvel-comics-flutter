import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/SensitiveWidget.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:random_color/random_color.dart';

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
    super.initState();
    imageProvider = CachedNetworkImageProvider(widget.hero.image);
    _updatePaletteGenerator();
  }

  Future<void> _updatePaletteGenerator() async {
    PaletteGenerator.fromImageProvider(imageProvider).then((value) {
      setState(() {
        paletteGenerator = value;
        dominantColor = paletteGenerator.dominantColor?.color;
        print('Dominant color ' + dominantColor.toString());
        invertColor = Color.fromARGB(
            dominantColor.alpha,
            255 - dominantColor.red,
            255 - dominantColor.green,
            255 - dominantColor.blue);
        print('Invert color ' + dominantColor.toString());
      });
    });
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
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Stack(children: <Widget>[
              SensitiveWidget(child: bg),
              SafeArea(
                  child: DetailHeroInfo(
                hero: hero,
                titleColor: invertColor,
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
      mainAxisAlignment: MainAxisAlignment.end,
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
        FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.keyboard_arrow_down),
            label: Text("Expand"))
      ],
    ));
  }
}
