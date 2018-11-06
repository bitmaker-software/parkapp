// External imports.
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../main.dart';

// This widget shows your personal QR code for parking.
class Code extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new TitleAppBar(
        title: Base.of(context).state == 1 ?
        Translations.of(context).text('enter_park') :
        Base.of(context).state == 4 ?
        Translations.of(context).text('exit_park') :
        Translations.of(context).text('your_park_code'),
      ),
      body: new Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Base.of(context).state != 2 ?
            new Text(
              Base.of(context).state == 1 ?
              Translations.of(context).text('scan_enter'):
              Translations.of(context).text('scan_exit'),
              style: Theme.of(context).textTheme.body2.copyWith(
                color: themeGrey,
              ),
            ) : null,
            new QrImage(
              data: Base.of(context).barcode,
              version: 3,
              errorCorrectionLevel: 0, //QrCorrectLevel.M
            ),
          ].where((widget) => widget != null).toList(),
        ),
      ),
    );
  }
}
