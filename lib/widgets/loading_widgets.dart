import 'package:flutter/material.dart';

class SmallLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset("images/loadingHeroes.gif");
  }
}

class BigLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset("images/bigLoadingHeroes.gif");
  }
}
