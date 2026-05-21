import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/hukamnama_model.dart';
import 'shared_prefs_service.dart';

class HukamnamaService {
  static const _cacheKey = 'hukamnama_sgpc_cache';
  static const _cacheDateKey = 'hukamnama_sgpc_cache_date';

  static const _months = [
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
  ];

  Future<HukamnamaModel?> fetchToday() async {
    final today = _todayKey();

    final cached = _loadFromCache(today);
    if (cached != null) return cached;

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
        log('HukamnamaService: HTTP ${response.statusCode}');
        return null;
      }

      final model = _parseHtml(response.body, today);
      if (model != null) await _saveToCache(today, model);
      return model;
    } catch (e) {
      log('HukamnamaService.fetchToday error: $e');
      return null;
    }
  }

  // ── cache helpers ──────────────────────────────────────────────────────────

  HukamnamaModel? _loadFromCache(String date) {
    try {
      final prefs = SharedPrefsService.instance;
      if (prefs.getString(_cacheDateKey) != date) return null;
      final json = prefs.getString(_cacheKey);
      if (json == null) return null;
      return HukamnamaModel.fromMap(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(String date, HukamnamaModel model) async {
    final prefs = SharedPrefsService.instance;
    await prefs.setString(_cacheDateKey, date);
    await prefs.setString(_cacheKey, jsonEncode(model.toMap()));
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ── HTML parsing ───────────────────────────────────────────────────────────

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
        translationPunjabi =
            p.replaceFirst('ਪੰਜਾਬੀ ਵਿਆਖਿਆ:', '').trim();
        inEnglish = false;
      } else if (p.contains('English Translation')) {
        inEnglish = true;
      } else if (inEnglish) {
        if (!_isDateLine(p)) englishParts.add(p);
      } else if (gurmukhi.isEmpty) {
        gurmukhi = p;
      }
    }

    // First line of gurmukhi block = raag / author (e.g. "ਧਨਾਸਰੀ ਭਗਤ ਰਵਿਦਾਸ ਜੀ ਕੀ")
    final gurLines = gurmukhi.split('\n');
    final source = gurLines.isNotEmpty ? gurLines.first.trim() : '';

    return HukamnamaModel(
      date: date,
      gurmukhi: gurmukhi,
      translationPunjabi: translationPunjabi,
      translationEnglish: englishParts.join('\n\n'),
      source: source,
    );
  }

  bool _isDateLine(String text) {
    // The final date paragraph contains month names and year — skip it
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
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#038;', '&')
        .trim();
  }
}
