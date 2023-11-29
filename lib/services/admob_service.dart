import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../api_key.dart';
import '../main.dart';

InterstitialAd? _interstitialAd;

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: useRealAdId ? realInterstitialAdId : testInterstitialAdId, // realInterstitialAdId and testInterstitialAdId are in hidden api_key.dart
    request: consentStatus == ConsentStatus.required ? const AdRequest(nonPersonalizedAds: true) : const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) => _interstitialAd = ad,
      onAdFailedToLoad: (LoadAdError error) {},
    ),
  );
}

void callInterstitialAd() {
  _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
    onAdDismissedFullScreenContent: (InterstitialAd ad) => ad.dispose(),
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) => ad.dispose(),
  );
  try{
    _interstitialAd?.show();
  } catch (e) {
    _interstitialAd?.dispose();
  }
}