import 'package:flutter/services.dart';

Future<String> loadAbi(String path) async {
  return await rootBundle.loadString(path);
}
