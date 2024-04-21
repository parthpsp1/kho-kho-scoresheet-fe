import 'package:flutter/services.dart';

FilteringTextInputFormatter customInputFormatters() {
  return FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z\s]'),
  );
}
