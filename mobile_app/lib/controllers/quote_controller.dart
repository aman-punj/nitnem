import 'dart:math';
import 'package:get/get.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';

class QuoteController extends GetxController {
  final QuoteService _service;

  final _homeQuote = const QuoteModel(text: '').obs;
  final _settingsQuote = const QuoteModel(text: '').obs;

  QuoteController({QuoteService? service})
      : _service = service ?? QuoteService();

  /// Quote shown at the bottom of the home screen.
  QuoteModel get homeQuote => _homeQuote.value;

  /// Quote shown at the bottom of the settings screen.
  QuoteModel get quote => _settingsQuote.value;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final quotes = await _service.fetchQuotes();
    if (quotes.isEmpty) return;
    final shuffled = List<QuoteModel>.from(quotes)..shuffle(Random());
    _homeQuote.value = shuffled[0];
    // Only assign a settings quote if we have at least 2, ensuring they differ.
    if (shuffled.length > 1) {
      _settingsQuote.value = shuffled[1];
    }
  }
}
