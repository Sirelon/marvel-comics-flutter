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
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child
    ]);
  }
}
