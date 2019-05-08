import 'package:flutter/material.dart';

class Copyright extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "Data provided by Marvel. © 2014 Marvel",
      style: Theme.of(context).primaryTextTheme.headline,
    );
  }
}
