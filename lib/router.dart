import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:marvel_heroes/AdMobHelper.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:marvel_heroes/hero/detail/detail.dart';
import 'package:marvel_heroes/widgets/loading_widgets.dart';
import 'package:palette_generator/palette_generator.dart';

class Router {
  final BuildContext context;

  Router(this.context);

  void navigateToHero(MarvelHero hero) async {

    AdMobHelper().showBetweenPagesIfNeeded();
    if (true) {
      // Without warm pallete
      Navigator.push(context,
          MaterialPageRoute(builder: (c) => HeroDetailPage(hero: hero)));
    } else {
      final dialogFeture = showDialog(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(content: SmallLoadingWidget()));

      try {
        // For "warm" our pallete generator.
        await PaletteGenerator.fromImageProvider(
                CachedNetworkImageProvider(hero.urlHolder.detailUrl))
            .timeout(Duration(seconds: 5))
            .catchError((e) => print(e));
      } catch (e) {
        print(e);
      } finally {
        // Hide Dialog
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (c) => HeroDetailPage(hero: hero)));
      }
    }
  }

  void closeCurrent() {
    Navigator.pop(context);
  }

  void launchURL(String url) async {
    try {
      await launch(
        url,
        option: new CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: new CustomTabsAnimation.slideIn()
          // or user defined animation.
//          animation: new CustomTabsAnimation(
//          startEnter: 'slide_up',
//          startExit: 'android:anim/fade_out',
//          endEnter: 'android:anim/fade_in',
//          endExit: 'slide_down',
//        )
          ,
          extraCustomTabs: <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
}
