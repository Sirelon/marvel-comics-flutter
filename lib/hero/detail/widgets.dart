import 'package:flutter/material.dart';
import 'package:marvel_heroes/hero/detail/detail.dart';

class ExpandButton extends StatelessWidget {

  final num _pageToGo;

  const ExpandButton(this._pageToGo) : super();

  @override
  Widget build(BuildContext context) {
    final state = HeroDetailPage.of(context);
    return SafeArea(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: FlatButton.icon(
              onPressed: () => state.goTo(_pageToGo),
              icon: Icon(Icons.keyboard_arrow_down),
              label: Text("Expand", style: state.titleStyle),
            )));
  }
}