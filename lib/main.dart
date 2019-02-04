import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/router.dart';
import 'network.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var headLineTheme = TextStyle(
      fontFamily: 'FF',
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.w800,
    );
    var titleTheme = TextStyle(
      fontFamily: 'Marvel',
      color: Colors.white,
      fontWeight: FontWeight.normal,
    );
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
          fontFamily: 'Marvel',
          splashColor: Theme.of(context).accentColor,
          primarySwatch: Colors.red,
          textTheme: TextTheme(title: titleTheme),
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
    _appBarTitle = new Text(widget.title);
    _filter.addListener(_onSearchChanged);
    fetchFuture = fetchHeroes(0);
    initialFilterState =
        FilterState(order: Order.MODIFIED_ASK, searchQuery: "");
    super.initState();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    var searchText = _filter.value.text;
    if (searchText == _lastSearchTxt) return;
    _debounce = Timer(const Duration(milliseconds: 700), () {
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
          Card(
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  this._isExpanded = !isExpanded;
                });
              },
              children: <ExpansionPanel>[
                ExpansionPanel(
                    isExpanded: this._isExpanded,
                    headerBuilder: (context, isExpand) => Center(
                            child: Text(
                          "Filters",
                          style: Theme.of(context).primaryTextTheme.headline,
                        )),
                    body: FiltersPanel(
                      state: initialFilterState,
                      stateCallback: stateCallback,
                    ))
              ],
            ),
            margin: EdgeInsets.all(0.0),
          ),
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
                            child: CircularProgressIndicator());
                      default:
                        return HeroTile(
                            heroes: snapshot.data,
                            filterState: initialFilterState);
                    }
                  }))
        ]));
  }

  void stateCallback(FilterState filterState) {
    setState(() {
      print("HEy i am here");
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
        this._appBarTitle = new Text(widget.title);
        _filter.clear();
      }
    });
  }
}

typedef void FilterStateChanged(FilterState newState);

class FiltersPanel extends StatefulWidget {
  final FilterState state;
  final FilterStateChanged stateCallback;

  FiltersPanel({Key key, this.state, this.stateCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _FiltersPanelState(state, stateCallback);
}

class _FiltersPanelState extends State<FiltersPanel> {
  Map<Order, String> orderMap;
  Order choosedOrder;
  FilterStateChanged stateCallback;
  FilterState filterState;

  _FiltersPanelState(FilterState state, FilterStateChanged stateCallback) {
    this.filterState = state;
    this.stateCallback = stateCallback;
  }

  @override
  void initState() {
    orderMap = {
      Order.NAME_ASK: "By name ask",
      Order.NAME_DESC: "By name desc",
      Order.MODIFIED_ASK: "By modified date ask",
      Order.MODIFIED_DESC: "By modified date desc"
    };
    choosedOrder = filterState.order;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderItems = orderMap.entries
        .map((entry) =>
            DropdownMenuItem(child: Text(entry.value), value: entry.key))
        .toList();

    return DropdownButton(
        items: orderItems,
        value: choosedOrder,
        onChanged: (value) {
          var newState = filterState.copy(newOrder: value);
          stateCallback(newState);
          setState(() {
            choosedOrder = value;
          });
        });
  }
}

class FilterState {
  final Order order;
  final String searchQuery;

  FilterState({this.order, this.searchQuery});

  FilterState copy({Order newOrder, String newSearchQuery}) {
    return FilterState(
        order: newOrder ?? order, searchQuery: newSearchQuery ?? searchQuery);
  }

  @override
  String toString() {
    return 'FilterState{order: $order, searchQuery: $searchQuery}';
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

  Widget _buildPage(List<MarvelHero> items) {
    return OrientationBuilder(builder: (context, orientation) {
      final length = items.length;
      final isLoading = loadStatus == LoadMoreStatus.LOADING;
      return StaggeredGridView.countBuilder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
          staggeredTileBuilder: (int index) =>
              StaggeredTile.fit((index == length) ? 3 : 1),
          itemCount: (isLoading) ? length + 1 : length,
          itemBuilder: (_, int index) {
            if (index == length) {
              return LinearProgressIndicator();
            }
            MarvelHero hero = items[index];
            print(hero.image);
            return Card(
                elevation: 2.0,
                margin: EdgeInsets.all(8.0),
                child: InkWell(
                    splashColor: Theme.of(context).accentColor,
                    onTap: () => _heroChoose(hero),
                    child: Column(
                      children: <Widget>[
                        CachedNetworkImage(
                            errorWidget: Icon(Icons.error),
                            imageUrl: hero.image,
                            placeholder: CircularProgressIndicator()),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(hero.name,
                                style:
                                    Theme.of(context).primaryTextTheme.headline,
                                textAlign: TextAlign.center)),
                      ],
                    )));
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
            print("I AM FETCHED $items");
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

  _heroChoose(MarvelHero hero) {
    print(hero);
    router.navigateToHero(hero);
  }
}

enum LoadMoreStatus { LOADING, STABLE }
