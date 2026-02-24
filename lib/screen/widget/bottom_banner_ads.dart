import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:swipe_n_merge/provider/ads_service.dart';
import 'package:swipe_n_merge/provider/consent_service.dart';
import 'package:swipe_n_merge/provider/game_provider.dart';

class BottomBannerAd extends StatelessWidget {
  const BottomBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdService, ConsentService>(
      builder: (context, adService, consentService, child) {
        if (!adService.isBannerAdLoaded && !consentService.isRequestLocationInEeaOrUk) {
          return const SizedBox.shrink();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (consentService.isRequestLocationInEeaOrUk)
              _buildPrivacyLinks(context, consentService),
            if (adService.isBannerAdLoaded && adService.bannerAd != null)
              _buildAdWidget(adService.bannerAd!)
            else
              const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildPrivacyLinks(BuildContext context, ConsentService consentService) {
    const textStyle = TextStyle(
      fontSize: 10,
      color: Color(0xFF776E65),
      decoration: TextDecoration.underline,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => consentService.showPrivacyOptions(),
            child: const Text("Privacy Settings Ads", style: textStyle),
          ),
          const Text("|", style: TextStyle(fontSize: 10, color: Color(0xFF776E65))),
          TextButton(
            onPressed: () => context.read<GameProvider>().openPrivacyPolicy(),
            child: const Text("Privacy Policy", style: textStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildAdWidget(BannerAd ad) {
    return SizedBox(
      height: ad.size.height.toDouble(),
      width: ad.size.width.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}