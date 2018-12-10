import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:vector_math/vector_math_64.dart';
import 'network.dart';
import 'package:sensors/sensors.dart';

class HeroDetailPage extends StatefulWidget {
  final MarvelHero hero;

  const HeroDetailPage({Key key, this.hero}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HeroDetailPageState();
}

class _HeroDetailPageState extends State<HeroDetailPage>
    with TickerProviderStateMixin {
  dynamic accelSubscription;

  double rotX;
  double rotY;
  double rotZ;
  Matrix4 perspective;
  AnimationController animation;

  // http://web.iitd.ac.in/~hegde/cad/lecture/L9_persproj.pdf
  // create perspective matrix
  @override
  void initState() {
    perspective = new Matrix4(
      1.0,
      0.0,
      0.0,
      0.0,
      //
      0.0,
      1.0,
      0.0,
      0.0,
      //
      0.0,
      0.0,
      1.0,
      1.0,
      //
      0.0,
      0.0,
      0.0,
      1.0,
    );
    rotX = 0;
    rotY = 0;
    rotZ = 0;

    animation = new AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..addListener(() {
        setState(() {
          rotZ = -Curves.easeOut.transform(animation.value) * 8 * pi;
        });
      });
    subscribeToChanges();
    super.initState();
  }

  @override
  void dispose() {
    accelSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var hero = widget.hero;

    var boxDecoration = new BoxDecoration(
      image: new DecorationImage(
        image: CachedNetworkImageProvider(widget.hero.image),
        fit: BoxFit.cover,
      ),
    );

    rotX *= 0.33;
    rotY *= 0.33;

    var transform = Transform(
      transform: perspective
        ..setRotationX(rotX)
        ..rotateY(rotY),
      alignment: FractionalOffset.center,
      child: Transform.scale(
          scale: 1.1,
          child: CachedNetworkImage(
              errorWidget: Icon(Icons.error),
              imageUrl: hero.image,
              placeholder: CircularProgressIndicator())),
    );

    print("rotX ${rotX}");

    return new Scaffold(
        appBar: AppBar(title: Text(widget.hero.name)),
        body: new Stack(children: <Widget>[transform]));
  }

  subscribeToChanges() {
    // https://www.digikey.com/en/articles/techzone/2011/may/using-an-accelerometer-for-inclination-sensing
    // https://pub.dartlang.org/packages/sensors
    // convert x, y, z acceleration into tilts for X and Y axis
    // Phone laying flat should give 0, 0
    accelSubscription =
        accelerometerEvents.listen((AccelerometerEvent ae) async {
//      print('X = ${ae.x}');
//      print('Y = ${ae.y}');
//      print('Z = ${ae.z}');
      // Do something with the event.
      double x2 = ae.x * ae.x;
      double y2 = ae.y * ae.y;
      double z2 = ae.z * ae.z;
//      await new Future.delayed(const Duration(seconds: 5));

      setState(() {
        rotX = -atan(ae.y / sqrt(x2 + z2));
        rotY = -atan(ae.x / sqrt(y2 + z2));
//        print('X tilt: $rotX Y tilt: $rotY');
      });
    });
  }
}
