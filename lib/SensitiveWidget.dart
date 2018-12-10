import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:sensors/sensors.dart';

class SensitiveWidget extends StatefulWidget {
  final Widget child;

  const SensitiveWidget({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SensitiveWidgetState();
}

class _SensitiveWidgetState extends State<SensitiveWidget> {
  dynamic accelSubscription;

  double rotX;
  double rotY;
  double rotZ;
  Matrix4 perspective;

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
      0.0,
      //
      0.0,
      0.0,
      0.0,
      1.0,
    );
    rotX = 0;
    rotY = 0;
    rotZ = 0;

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
    rotX *= 0.33;
    rotY *= 0.33;

    var transform = Transform(
      transform: perspective
        ..setRotationX(rotX)
        ..rotateY(rotY),
      alignment: FractionalOffset.center,
      child: Transform.scale(scale: 1.15, child: widget.child),
    );

    return transform;
  }

  subscribeToChanges() {
    // https://www.digikey.com/en/articles/techzone/2011/may/using-an-accelerometer-for-inclination-sensing
    // https://pub.dartlang.org/packages/sensors
    // convert x, y, z acceleration into tilts for X and Y axis
    // Phone laying flat should give 0, 0
    accelSubscription = accelerometerEvents.listen((AccelerometerEvent ae) {
      double x2 = ae.x * ae.x;
      double y2 = ae.y * ae.y;
      double z2 = ae.z * ae.z;

      setState(() {
        rotX = -atan(ae.y / sqrt(x2 + z2));
        rotY = -atan(ae.x / sqrt(y2 + z2));
//        print('X tilt: $rotX Y tilt: $rotY');
      });
    });
  }
}
