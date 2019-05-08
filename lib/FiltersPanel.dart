import 'package:flutter/material.dart';

enum Order { NAME_ASK, NAME_DESC, MODIFIED_ASK, MODIFIED_DESC }

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
      Order.NAME_ASK: "by name ask",
      Order.NAME_DESC: "by name desc",
      Order.MODIFIED_ASK: "by modified date ask",
      Order.MODIFIED_DESC: "by modified date desc"
    };
    choosedOrder = filterState.order;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    return FlatButton.icon(
//        onPressed: _showSordedOptions,
//        icon: Icon(Icons.sort),
//        label: Text(orderMap[choosedOrder], textScaleFactor: 1.3));

    final orderItems = orderMap.entries
        .map((entry) => DropdownMenuItem(
              child: Text(
                "Filter ${entry.value}",
                style: TextStyle(color: Color(0xFFef5350)),
              ),
              value: entry.key,
            ))
        .toList();

    return Container(
        color: Colors.white54,
        child: DropdownButtonHideUnderline(
            child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                    items: orderItems,
                    style: TextStyle(color: Colors.white),
                    value: choosedOrder,
                    onChanged: (value) {
                      var newState = filterState.copy(newOrder: value);
                      stateCallback(newState);
                      setState(() {
                        choosedOrder = value;
                      });
                    }))));
  }

  void _showSordedOptions() async {
    final orderItems = orderMap.entries
        .map((entry) => SimpleDialogOption(
            child: Text(entry.value, textScaleFactor: 2.0),
            onPressed: () => Navigator.pop(context, entry)))
        .toList();

    MapEntry<Order, String> value = await showDialog(
        context: context, builder: (con) => SimpleDialog(children: orderItems));
    if (value == null) return;

    print("Show Sorted Options" + value.toString());
    var newState = filterState.copy(newOrder: value.key);
    stateCallback(newState);
    setState(() {
      choosedOrder = value.key;
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
