import 'package:flutter/foundation.dart';

/// Set to `true` during local development to use bundled JSON fixtures
/// instead of hitting Firebase Firestore.
///
/// The getter [useMockData] also checks [kDebugMode], so this flag has
/// zero effect in release builds — it can never accidentally ship.
const bool kUseMockData = true;

/// Whether the app should use local JSON mock data.
/// Always `false` in release builds regardless of [kUseMockData].
bool get useMockData => kDebugMode && kUseMockData;
