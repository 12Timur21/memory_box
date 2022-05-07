import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';

class InitialSettings {
  InitialSettings() {
    // updateBootomUIColor();
    updatePhoneFormatter();
  }

  void updateBootomUIColor() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(246, 246, 246, 1),
      ),
    );
  }

  void updatePhoneFormatter() {
    PhoneInputFormatter.replacePhoneMask(
      countryCode: 'UA',
      newMask: '+000 (00) 000 00 00',
    );

    PhoneInputFormatter.replacePhoneMask(
      countryCode: 'RU',
      newMask: '+0 (000) 000 00 00',
    );
  }
}
