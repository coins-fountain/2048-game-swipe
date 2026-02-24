import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentService extends ChangeNotifier {
  bool _isConsentGiven = false;
  bool _isConsentRequired = false;
  bool _isRequestLocationInEeaOrUk = false;

  bool get isConsentGiven => _isConsentGiven;
  bool get isConsentRequired => _isConsentRequired;
  bool get isRequestLocationInEeaOrUk => _isRequestLocationInEeaOrUk;

  Future<void> initializeConsent() async {
    final completer = Completer<void>();

    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        final status = await ConsentInformation.instance.getConsentStatus();

        _isConsentGiven = status == ConsentStatus.obtained;
        _isConsentRequired = status == ConsentStatus.required;

        final inEeaOrUk = await ConsentInformation.instance.isConsentFormAvailable();
        _isRequestLocationInEeaOrUk = inEeaOrUk;

        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
          (FormError error) {
        if (!completer.isCompleted) completer.complete();
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  Future<void> showConsentFlow() async {
    final completer = Completer<void>();

    ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) async {
      final status = await ConsentInformation.instance.getConsentStatus();

      _isConsentGiven = status == ConsentStatus.obtained;
      _isConsentRequired = status == ConsentStatus.required;

      notifyListeners();
      completer.complete();
    });

    return completer.future;
  }

  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();

    ConsentForm.showPrivacyOptionsForm((FormError? error) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      _isConsentGiven = status == ConsentStatus.obtained;
      notifyListeners();
      completer.complete();
    });

    return completer.future;
  }
}