import 'package:flutter/material.dart';
import 'package:marvel_heroes/detail.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:path/path.dart';

class Router {
  final BuildContext context;

  Router(this.context);

  void navigateToHero(MarvelHero hero) {
    Navigator.push(
        context, MaterialPageRoute(builder: (c) => HeroDetailPage(hero: hero)));
  }

  void closeCurrent() {
    Navigator.pop(context);
  }
}
