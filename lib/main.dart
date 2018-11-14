import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:marvel_heroes/entities.dart';
import 'network.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var headLineTheme = TextStyle(
      fontFamily: 'FF',
      color: Theme.of(context).accentColor,
      fontWeight: FontWeight.w800,
    );
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
          fontFamily: 'Marvel',
          primarySwatch: Colors.blue,
          primaryTextTheme: TextTheme(headline: headLineTheme)),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: FutureBuilder(
            future: fetchHeroes(),
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
                  return _buildPage(snapshot.data);
              }
            }));
  }

  Widget _buildPage(List<MarvelHero> items) {
    return OrientationBuilder(builder: (context, orientation) {
      return StaggeredGridView.countBuilder(
          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
          itemCount: items.length,
          itemBuilder: (_, int index) {
            MarvelHero hero = items[index];
            print(hero.image);
            return Card(
                elevation: 2.0,
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
//                    Image.network(hero.image),
                    CachedNetworkImage(
                        errorWidget: Icon(Icons.error),
                        imageUrl: hero.image,
                        placeholder: CircularProgressIndicator()),
                    Text(hero.name,
                        style: Theme.of(context).primaryTextTheme.headline,
                        textAlign: TextAlign.center),
                  ],
                ));
          });
    });
  }
}
