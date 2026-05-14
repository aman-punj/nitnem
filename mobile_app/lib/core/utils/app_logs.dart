import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

void appLogs(
  String message, {
  Object? data,
  String tag = 'APP_LOG',
}) {
  final prefix = '[$tag] $message';

  if (data == null) {
    debugPrint(prefix);
    log(prefix, name: tag);
    return;
  }

  String encoded;
  try {
    encoded = const JsonEncoder.withIndent('  ').convert(data);
  } catch (_) {
    encoded = data.toString();
  }

  final payload = '$prefix\n$encoded';
  debugPrint(payload);
  log(payload, name: tag);
}
