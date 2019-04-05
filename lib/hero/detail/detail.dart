import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marvel_heroes/hero/detail/hero_image.dart';
import 'package:marvel_heroes/hero/detail/comics_list.dart';
import 'package:marvel_heroes/hero/detail/hero_info.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:random_color/random_color.dart';

class HeroDetailPage extends StatefulWidget {
  final MarvelHero hero;

  HeroDetailPage({Key key, @required this.hero}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HeroPageState();

  static HeroPageState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_Inherited) as _Inherited)
        .data;
  }
}

class HeroPageState extends State<HeroDetailPage> {
  ImageProvider imageProvider;

  Color dominantColor = Colors.white;
  Color invertColor = Colors.white;
  Brightness brightness = Brightness.dark;

  RandomColor _randomColor = RandomColor();
  final PageController _pageController = PageController();

  final padding = 8.0;

  MarvelHero hero;

  TextStyle titleStyle;

  @override
  Widget build(BuildContext context) => _Inherited(this, new _HeroScreen());

  void goTo(int pageNumber) {
    _pageController.animateToPage(pageNumber,
        duration: Duration(seconds: 1), curve: Curves.ease);
  }

  @override
  void initState() {
    hero = widget.hero;
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

        titleStyle = TextStyle(
            fontFamily: 'Black',
            color: invertColor,
            letterSpacing: padding,
            fontSize: 16.0);

        print('Dominant color $dominantColor ');
      });
    }, onError: (e) => debugPrint(e));
  }
}

class _HeroScreen extends StatelessWidget {
  const _HeroScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HeroPageState state = HeroDetailPage.of(context);

    final iconAppBarTheme = IconThemeData(color: state.invertColor);

    var pages = <Widget>[];
    pages.add(HeroImage());

    var description = state.hero.description;
    if (description != null && description.isNotEmpty) {
      pages.add(DetailHeroInfo());
    }
    pages.add(HeroComicsPage());

    return new Scaffold(
        appBar: AppBar(
          title: Text(
            state.hero.name,
            style: TextStyle(color: state.invertColor),
          ),
          backgroundColor: state.dominantColor,
          brightness: state.brightness,
          iconTheme: iconAppBarTheme,
        ),
        body: PageView(
          controller: state._pageController,
          scrollDirection: Axis.vertical,
          children: pages,
        ));
  }
}

class _Inherited extends InheritedWidget {
  final HeroPageState data;

  _Inherited(this.data, child) : super(child: child);

  @override
  bool updateShouldNotify(_Inherited oldWidget) => true;
}
