import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredWidget extends StatelessWidget {
  final Widget child;
  final ImageProvider imageProvider;

  const BlurredWidget(
      {Key key, @required this.imageProvider, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image(
          image: imageProvider,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover),
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child
    ]);
  }
}
