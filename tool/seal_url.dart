import 'dart:io';

import 'package:rakku/core/url_cipher.dart';

void main(List<String> arguments) {
  stdout.writeln(UrlCipher.seal(arguments.first));
}