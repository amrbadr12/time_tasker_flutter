import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

inAppRatingBuilder(BuildContext context, {Function onLowReviewCallback}) async {
  if (onLowReviewCallback == null) onLowReviewCallback = () {};
  RateMyApp _rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_tt',
      minDays: 1,
      minLaunches: 3,
      remindDays: 3,
      remindLaunches: 1,
      googlePlayIdentifier: 'com.fiona.timetasker',
      appStoreIdentifier: '1499489083');
  _rateMyApp.init().then((_) {
    if (_rateMyApp.shouldOpenDialog) {
      _rateMyApp.showStarRateDialog(
        context,
        title: 'Enjoying TimeTasker?',
        message:
            'Do you like using TimeTasker? Then please take a little bit of your time to leave a rating :',
        // The dialog message.
        actionsBuilder: (context, stars) {
          // Triggered when the user updates the star rating.
          return [
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                if (stars != null) {
                  if (stars.round() < 4)
                    onLowReviewCallback();
                  else {
                    _rateMyApp.save().then((value) {
                      _rateMyApp.launchStore();
                      Navigator.pop<RateMyAppDialogButton>(
                          context, RateMyAppDialogButton.rate);
                    });
                  }
                }
              },
            ),
          ];
        },
        ignoreNativeDialog: false,
        dialogStyle: DialogStyle(
          // Custom dialog styles.
          titleAlign: TextAlign.center,
          messageAlign: TextAlign.center,
          messagePadding: EdgeInsets.only(bottom: 20),
        ),
        starRatingOptions: StarRatingOptions(),
        // Custom star bar rating options.
        onDismissed: () => _rateMyApp.callEvent(RateMyAppEventType
            .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
      );
    }
  });
}
