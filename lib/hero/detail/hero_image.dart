import 'package:flutter/material.dart';
import 'package:marvel_heroes/hero/detail/detail.dart';
import 'package:marvel_heroes/widgets/SensitiveWidget.dart';

class HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HeroPageState state = HeroDetailPage.of(context);

    return Stack(children: <Widget>[
      SensitiveWidget(
          child: Image(
              image: state.imageProvider,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center)),
      SafeArea(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton.icon(
                onPressed: () => state.goTo(1),
                icon: Icon(Icons.keyboard_arrow_down),
                label: Text("Expand", style: state.titleStyle),
              )))
    ]);
  }
}
