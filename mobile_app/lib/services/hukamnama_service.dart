import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/hukamnama_model.dart';
import 'shared_prefs_service.dart';

class HukamnamaService {
  static const _cacheKey = 'hukamnama_cache';
  static const _cacheDateKey = 'hukamnama_cache_date';

  static const _months = [
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
  ];

  final FirebaseFirestore _firestore;

  HukamnamaService({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;

  /// Fallback chain:
  /// 1. Firestore hukamnama/today  → return even if it's yesterday's (most recent available)
  /// 2. Local SharedPrefs cache    → avoids a blank screen on Firestore error
  /// 3. Direct SGPC scrape         → emergency only
  ///
  /// When Firestore has data but it's not today's, a fire-and-forget POST to
  /// the backend is made so the cron catch-up runs immediately.
  Future<HukamnamaModel?> fetchToday({String backendUrl = ''}) async {
    final today = _todayKey();

    // ── 1. Firestore ─────────────────────────────────────────────────────────
    try {
      final doc = await _firestore
          .collection('hukamnama')
          .doc('today')
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists && doc.data() != null) {
        final model = HukamnamaModel.fromMap(doc.data()!);
        await _saveToCache(model);

        if (model.date != today && backendUrl.isNotEmpty) {
          // Firestore has yesterday's data — cron hasn't run yet.
          // Nudge the backend in the background; don't await.
          _triggerBackendSync(backendUrl);
        }

        return model;
      }
    } catch (e) {
      log('HukamnamaService: Firestore unavailable: $e');
    }

    // ── 2. Local cache ────────────────────────────────────────────────────────
    final cached = _loadFromCache();
    if (cached != null) {
      log('HukamnamaService: serving from local cache (${cached.date})');
      return cached;
    }

    // ── 3. Emergency SGPC scrape ──────────────────────────────────────────────
    log('HukamnamaService: falling back to direct SGPC scrape');
    return _scrapeSgpc(today);
  }

  // ── Backend trigger (fire-and-forget) ────────────────────────────────────

  void _triggerBackendSync(String backendUrl) {
    final url = backendUrl.endsWith('/')
        ? '${backendUrl}sync-hukamnama'
        : '$backendUrl/sync-hukamnama';

    http
        .post(Uri.parse(url))
        .timeout(const Duration(seconds: 30))
        .then((_) => log('HukamnamaService: backend sync triggered'))
        .catchError((e) => log('HukamnamaService: backend trigger failed: $e'));
  }

  // ── Cache ─────────────────────────────────────────────────────────────────

  HukamnamaModel? _loadFromCache() {
    try {
      final prefs = SharedPrefsService.instance;
      final json = prefs.getString(_cacheKey);
      if (json == null) return null;
      return HukamnamaModel.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(HukamnamaModel model) async {
    final prefs = SharedPrefsService.instance;
    await prefs.setString(_cacheDateKey, model.date);
    await prefs.setString(_cacheKey, jsonEncode(model.toMap()));
  }

  // ── SGPC emergency scrape ─────────────────────────────────────────────────

  Future<HukamnamaModel?> _scrapeSgpc(String date) async {
    try {
      final now = DateTime.now();
      final url =
          'https://sgpc.net/${now.day}-${_months[now.month - 1]}-${now.year}/';
      final response = await http
          .get(Uri.parse(url), headers: {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,pa;q=0.9,en;q=0.8',
          })
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        log('HukamnamaService SGPC: HTTP ${response.statusCode}');
        return null;
      }

      final model = _parseHtml(response.body, date);
      if (model != null) await _saveToCache(model);
      return model;
    } catch (e) {
      log('HukamnamaService SGPC scrape error: $e');
      return null;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ── HTML parsing (mirrors backend logic) ─────────────────────────────────

  HukamnamaModel? _parseHtml(String html, String date) {
    final articleStart = html.indexOf('<article class="small single">');
    final articleEnd = html.lastIndexOf('</article>');
    if (articleStart == -1 || articleEnd == -1) {
      log('HukamnamaService: article block not found');
      return null;
    }

    final articleHtml = html.substring(articleStart, articleEnd);
    final pRegex = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);

    final paragraphs = pRegex
        .allMatches(articleHtml)
        .map((m) => _stripHtml(m.group(1) ?? '').trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) return null;

    String gurmukhi = '';
    String translationPunjabi = '';
    final englishParts = <String>[];
    bool inEnglish = false;

    for (final p in paragraphs) {
      if (p.startsWith('ਪੰਜਾਬੀ ਵਿਆਖਿਆ:')) {
        translationPunjabi = p.replaceFirst('ਪੰਜਾਬੀ ਵਿਆਖਿਆ:', '').trim();
        inEnglish = false;
      } else if (p.contains('English Translation')) {
        inEnglish = true;
      } else if (inEnglish) {
        if (!_isDateLine(p)) englishParts.add(p);
      } else if (gurmukhi.isEmpty) {
        gurmukhi = p;
      }
    }

    if (gurmukhi.isEmpty) return null;

    final sourceLine = gurmukhi.split('\n').first.trim();
    final source = sourceLine.isNotEmpty
        ? 'Sri Darbar Sahib, Amritsar — $sourceLine'
        : 'Sri Darbar Sahib, Amritsar';

    return HukamnamaModel(
      date: date,
      gurmukhi: gurmukhi,
      translationPunjabi: translationPunjabi,
      translationEnglish: englishParts.join('\n\n'),
      source: source,
    );
  }

  bool _isDateLine(String text) {
    return RegExp(
            r'(January|February|March|April|May|June|July|August|September'
            r'|October|November|December)',
            caseSensitive: false)
        .hasMatch(text) &&
        RegExp(r'\d{4}').hasMatch(text);
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#038;', '&')
        .trim();
  }
}
