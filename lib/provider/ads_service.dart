import 'package:flutter/material.dart';
import 'package:swipe_n_merge/utils/ads_helper.dart';
import 'consent_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends ChangeNotifier {
  final ConsentService consentService;

  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;

  InterstitialAd? interstitialAd;
  bool isInterstitialAdLoaded = false;
  bool isInterstitialLoading = false;

  RewardedAd? rewardedAd;
  bool isRewardedAdLoaded = false;

  DateTime? _lastInterstitialShown;
  final Duration _interstitialCooldown = const Duration(minutes: 1);

  AdService({required this.consentService}) {
    _initializeAndLoad();
    consentService.addListener(_handleConsentChange);
  }

  AdRequest get _adRequest => AdRequest(nonPersonalizedAds: !consentService.isConsentGiven);

  bool get canShowInterstitial {
    if (_lastInterstitialShown == null) return true;
    final diff = DateTime.now().difference(_lastInterstitialShown!);
    return diff >= _interstitialCooldown;
  }

  void _handleConsentChange() {
    reloadAllAds();
  }

  Future<void> _initializeAndLoad() async {
    try {
      print("fradricastttttt");
      await consentService.initializeConsent();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
      );
      print("fradricasttttttkesinienggaa" );
      await MobileAds.instance.initialize();
      print("fradricasttttttkesinienggaa" );
      _loadInitialAds();
    } catch (e) {
      debugPrint("Error AdService: $e");
    }
  }

  void _loadInitialAds() {
    _loadBannerAd();
    print("fradricastttt2222233");
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void reloadAllAds() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();

    isBannerAdLoaded = false;
    isInterstitialAdLoaded = false;
    isRewardedAdLoaded = false;
    notifyListeners();

    _loadInitialAds();
  }

  void _loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: _adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerAdLoaded = false;
          notifyListeners();
          Future.delayed(const Duration(seconds: 30), _loadBannerAd);
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    if (isInterstitialLoading) return;
    isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialAdLoaded = true;
          isInterstitialLoading = false;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          isInterstitialAdLoaded = false;
          isInterstitialLoading = false;
          notifyListeners();
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: _adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          isRewardedAdLoaded = false;
          notifyListeners();
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  void showInterstitial(BuildContext context, {void Function()? onClosed}) {
    if (!canShowInterstitial) {
      onClosed?.call();
      return;
    }

    if (interstitialAd != null && isInterstitialAdLoaded) {
      _showActualAd(onClosed);
    } else {
      _waitForAdThenShow(context, onClosed);
    }
  }

  void _showActualAd(void Function()? onClosed) {
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastInterstitialShown = DateTime.now();
        ad.dispose();
        _loadInterstitialAd();
        onClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
        onClosed?.call();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
    isInterstitialAdLoaded = false;
    notifyListeners();
  }

  Future<void> _waitForAdThenShow(BuildContext context, void Function()? onClosed) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    _loadInterstitialAd();

    int attempts = 0;
    while (interstitialAd == null && attempts < 25) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    Navigator.of(context, rootNavigator: true).pop();

    if (interstitialAd != null && isInterstitialAdLoaded) {
      _showActualAd(onClosed);
    } else {
      onClosed?.call();
    }
  }

  void showRewardedAd({
    required void Function() onRewardEarned,
    void Function()? onAdDismissed,
    void Function()? onAdFailed,
  }) {
    if (rewardedAd == null || !isRewardedAdLoaded) {
      onAdFailed?.call();
      return;
    }

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        onAdFailed?.call();
      },
    );

    rewardedAd!.show(onUserEarnedReward: (ad, reward) => onRewardEarned());
    rewardedAd = null;
    isRewardedAdLoaded = false;
    notifyListeners();
  }

  @override
  void dispose() {
    consentService.removeListener(_handleConsentChange);
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
    super.dispose();
  }
}