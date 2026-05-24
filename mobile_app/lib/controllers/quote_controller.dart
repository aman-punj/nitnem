import 'dart:math';
import 'package:get/get.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';

class QuoteController extends GetxController {
  final QuoteService _service;

  final _quote = const QuoteModel(text: '').obs;

  QuoteController({QuoteService? service})
      : _service = service ?? QuoteService();

  QuoteModel get quote => _quote.value;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final quotes = await _service.fetchQuotes();
    if (quotes.isNotEmpty) {
      final shuffled = List<QuoteModel>.from(quotes)..shuffle(Random());
      _quote.value = shuffled.first;
    }
  }
}
