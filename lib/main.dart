import 'dart:async';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:marvel_heroes/FiltersPanel.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/router.dart';
import 'package:marvel_heroes/widgets/Copyright.dart';
import 'package:marvel_heroes/widgets/loading_widgets.dart';

import 'network.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var headLineTheme = TextStyle(
      fontFamily: 'FF',
      color: const Color(0xFFef5350),
      fontWeight: FontWeight.w800,
    );
    var titleTheme = TextStyle(
      fontFamily: 'Marvel',
      color: Colors.white,
      fontWeight: FontWeight.normal,
    );
    const bgColor = const Color(0xFFefefef);

    FirebaseAnalytics analytics = FirebaseAnalytics();

    return new MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: 'Marvel Heroes',
      theme: new ThemeData(
          fontFamily: 'Marvel',
          backgroundColor: bgColor,
          scaffoldBackgroundColor: bgColor,
          splashColor: const Color(0xFF263238),
          primaryColor: const Color(0xFFef5350),
          primaryColorLight: const Color(0xFFff867c),
          primaryColorDark: const Color(0xFFb61827),
          accentColor: const Color(0xFF263238),
//          primarySwatch: Colors.redAccent,
          textTheme: TextTheme(title: titleTheme),
          primaryTextTheme: TextTheme(headline: headLineTheme)),
      home: new MyHomePage(title: 'Marvel Heroes'),
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
  bool _isExpanded = false;
  Future<List<MarvelHero>> fetchFuture;
  FilterState initialFilterState;

  // controls the text label we use as a search bar
  final TextEditingController _filter = new TextEditingController();
  Timer _debounce;
  String _lastSearchTxt;
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle;

  @override
  void initState() {
    initialFilterState =
        FilterState(order: Order.MODIFIED_ASK, searchQuery: "");
    _appBarTitle = createAppBarWidget();
    _filter.addListener(_onSearchChanged);
    fetchFuture = fetchHeroes(0);

    super.initState();
  }

  Row createAppBarWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Text(widget.title),
        FiltersPanel(
          state: initialFilterState,
          stateCallback: stateCallback,
        ),
      ],
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    var searchText = _filter.value.text;
    if (searchText == _lastSearchTxt) return;
    _debounce = Timer(const Duration(seconds: 2), () {
      print("Listner for search input $searchText");
      var state = initialFilterState.copy(newSearchQuery: searchText);
      stateCallback(state);
    });
  }

  @override
  void dispose() {
    _filter.removeListener(_onSearchChanged);
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: _appBarTitle,
          actions: <Widget>[
            IconButton(icon: _searchIcon, onPressed: _searchPressed)
          ],
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: FutureBuilder(
                  future: fetchFuture,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Align(
                            alignment: Alignment.center,
                            child: BigLoadingWidget());
                      default:
                        return HeroTile(
                            heroes: snapshot.data,
                            filterState: initialFilterState);
                    }
                  })),
          Copyright(),
        ]));
  }

  void stateCallback(FilterState filterState) {
    print("STATE CALLBACK " + filterState.toString());
    setState(() {
      initialFilterState = filterState;
      fetchFuture =
          fetchHeroesWithFilters(0, filterState.order, filterState.searchQuery);
    });
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          style: Theme.of(context).textTheme.title,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search hero...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = createAppBarWidget();
        _filter.clear();
      }
    });
  }
}

class HeroTile extends StatefulWidget {
  final List<MarvelHero> heroes;
  final FilterState filterState;

  HeroTile({Key key, this.heroes, this.filterState}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HeroTileState(filterState);
}

class _HeroTileState extends State<HeroTile> {
  Router router;

  LoadMoreStatus loadStatus = LoadMoreStatus.STABLE;
  List<MarvelHero> heroes;
  int currentPage = 1;
  final ScrollController scrollController = new ScrollController();
  CancelableOperation movieOperation;

  final FilterState filterState;

  _HeroTileState(this.filterState);

  @override
  Widget build(BuildContext context) => NotificationListener(
      child: _buildPage(heroes), onNotification: _onNotification);

  Widget _buildPage(List<MarvelHero> heroes) {
    List<dynamic> items = List.from(heroes);

//    items.insert(3, "ASdadasd asd asd asd");

    return OrientationBuilder(builder: (context, orientation) {
      final length = items.length;
      final isLoading = loadStatus == LoadMoreStatus.LOADING;
      return StaggeredGridView.countBuilder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
          staggeredTileBuilder: (int index) => _buildTileBuilder(items, index),
          itemCount: (isLoading) ? length + 1 : length,
          itemBuilder: (_, int index) {
            if (index == length) {
              return LinearProgressIndicator();
            }
            final item = items[index];
            if (item is MarvelHero) {
              return _HeroCard(hero: item);
            } else {
              return Text("$item");
            }
          });
    });
  }

  @override
  void initState() {
    heroes = widget.heroes;
    router = Router(context);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    if (movieOperation != null) movieOperation.cancel();
    super.dispose();
  }

  bool _onNotification(Notification notification) {
    if (notification is ScrollUpdateNotification) {
      if (scrollController.position.maxScrollExtent > scrollController.offset &&
          scrollController.position.maxScrollExtent - scrollController.offset <=
              50) {
        if (loadStatus != null && loadStatus == LoadMoreStatus.STABLE) {
          setState(() {
            loadStatus = LoadMoreStatus.LOADING;
          });
          fetchHeroesWithFilters(
                  currentPage, filterState.order, filterState.searchQuery)
              .then((items) {
            currentPage++;
            loadStatus = LoadMoreStatus.STABLE;
            setState(() {
              heroes.addAll(items);
            });
          });
        }
      }
    }
    return true;
  }

  _buildTileBuilder(List items, int index) {
    final length = items.length;
    int fit = 1;
    if (index == length) {
      fit = 3;
    }

    if (!(items[index] is MarvelHero)) fit = 3;

    return StaggeredTile.fit(fit);
  }
}

class _HeroCard extends StatelessWidget {
  final MarvelHero hero;

  const _HeroCard({Key key, this.hero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2.0,
        margin: EdgeInsets.all(8.0),
        child: InkWell(
            splashColor: Theme.of(context).accentColor,
            onTap: () => Router(context).navigateToHero(hero),
            child: Column(
              children: <Widget>[
                CachedNetworkImage(
                    errorWidget: Icon(Icons.error),
                    imageUrl: hero.image,
                    placeholder: SmallLoadingWidget()),
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(hero.name,
                        style: Theme.of(context).primaryTextTheme.headline,
                        textAlign: TextAlign.center)),
              ],
            )));
  }
}

enum LoadMoreStatus { LOADING, STABLE }
