import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/widgets.dart';

class AdMobHelper {
  static final AdMobHelper _instance = new AdMobHelper._internal();

  static const bannerId = "ca-app-pub-7516059448019339/9429144878";
  static const interestingId = "ca-app-pub-7516059448019339/7211843947";

//  static String interestingId = InterstitialAd.testAdUnitId;
//  static String bannerId = BannerAd.testAdUnitId;

  factory AdMobHelper() {
    return _instance;
  }

  AdMobHelper._internal();

  void init() {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-7516059448019339~7760839980");
  }

  MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      'Marvel',
      'Comics',
      'Hero',
      'Heroes',
      'Superhero',
      'Avengers',
      'Thanos',
      'SpiderMan',
      'endgame',
      'avengers endgame',
      'avengers infinity war',
      'infinity war'
    ],
    contentUrl: 'https://www.marvel.com',
    childDirected: true,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  InterstitialAd _interstitialAd;

  void showBetweenPages([State state]) {
    if (state != null && !state.mounted) return;
    if (_interstitialAd == null) _interstitialAd = _createInterstitialAd();
    AdMobHelper()._createInterstitialAd()
      ..load()
      ..show();
  }

  InterstitialAd _createInterstitialAd() {
    // Replace
    return InterstitialAd(
      adUnitId: interestingId,
      targetingInfo: _targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
      },
    );
  }

  void hideInterestitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  // Banners
  BannerAd _bannerAd;

  void showBanner([State state]) {
    if (state != null && !state.mounted) return;
    if (_bannerAd == null) _bannerAd = _createBannerAd();

    // typically this happens well before the ad is shown
    _bannerAd
      ..load()
      ..show(
        // Banner Position
        anchorType: AnchorType.bottom,
      );
  }

  void hideBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  BannerAd _createBannerAd() {
    return BannerAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: bannerId,
      size: AdSize.smartBanner,
      targetingInfo: _targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  var _counter = 0;

  void showBetweenPagesIfNeeded() {
    _counter++;
    if (_counter % 7 == 0) {
      showBetweenPages();
    }
  }
}
