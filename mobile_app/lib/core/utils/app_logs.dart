import 'dart:convert';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

void appLogs(
  String message, {
  Object? data,
  String tag = 'APP_LOG',
  Object? error,
  StackTrace? stackTrace,
}) {
  final prefix = '[$tag] $message';

  if (data == null) {
    debugPrint(prefix);
    log(prefix, name: tag);
  } else {
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

  if (error != null && !kDebugMode) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: prefix,
      fatal: false,
    );
  }
}
